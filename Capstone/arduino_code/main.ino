#include <TimerOne.h>
#include <Arduino.h>
#include <SPI.h>
#if not defined (_VARIANT_ARDUINO_DUE_X_) && not defined (_VARIANT_ARDUINO_ZERO_)
  #include <SoftwareSerial.h>
#endif

#include "Adafruit_BLE.h"
#include "Adafruit_BluefruitLE_SPI.h"
#include "Adafruit_BluefruitLE_UART.h"

#include "BluefruitConfig.h"

// Create the bluefruit object, either software serial...uncomment these lines
/*
SoftwareSerial bluefruitSS = SoftwareSerial(BLUEFRUIT_SWUART_TXD_PIN, BLUEFRUIT_SWUART_RXD_PIN);

Adafruit_BluefruitLE_UART ble(bluefruitSS, BLUEFRUIT_UART_MODE_PIN,
                      BLUEFRUIT_UART_CTS_PIN, BLUEFRUIT_UART_RTS_PIN);
*/

/* ...or hardware serial, which does not need the RTS/CTS pins. Uncomment this line */
// Adafruit_BluefruitLE_UART ble(BLUEFRUIT_HWSERIAL_NAME, BLUEFRUIT_UART_MODE_PIN);

/* ...hardware SPI, using SCK/MOSI/MISO hardware SPI pins and then user selected CS/IRQ/RST */
Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

/* ...software SPI, using SCK/MOSI/MISO user-defined SPI pins and then user selected CS/IRQ/RST */
//Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_SCK, BLUEFRUIT_SPI_MISO,
//                             BLUEFRUIT_SPI_MOSI, BLUEFRUIT_SPI_CS,
//                             BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);


// A small helper
void error(const __FlashStringHelper*err) {
  Serial.println(err);
  while (1);
}
/*           
 *            The service information
 */
// Sending
int32_t ServiceId;
int32_t cal_err_id;
int32_t cal_done_id;
int32_t count_correct_rep_id;
int32_t fatigue_flag_id;
int32_t timeout_flag_id;


// Receive
int32_t calibrate_flag_id;
int32_t start_flag_id;
int32_t stop_flag_id;

#define NUM_READS 100

int promtp = 1;
int block_start = 1;
int stop_block = 1;

int sensorValue = 0;
float print_value = 0.00;

int upper_bound = 0;
int temp [3] = {0};

int stop_flag = 0;
int start_flag = 0;
int calibrate_flag = 0;
int calibrate_error = 0;

int last_two_flag = 0;
int last_two = 2;

int timeout_count = 0;
int timeout_flag = 0;

int rep_correct_flag = 0;
int count_correct_rep = 0;

int upper_bound_flag = 0;

int temp_voltage = 0;

int first_rep_flag = 1;
int fatigue_flag = 0;

int have_two_voltage_flag = 0;
int previous_voltage = 0;
int current_voltage = 0;

int do_only_one = 1;
int annouce_only_one = 1;
int total_block = 0;

  float increase_percentage = 0.00;
  int start_action = 0;
  int cal_err;
  int cal_done;

int Calibrate();
void timerIsr();
int receive_value(int32_t id);
void send_value (int n, int32_t id);
int readSensor(int sensorpin);

void setup() {
  bool success;
  // initialize serial communication at 9600 bits per second:
  //Serial.begin(115200);
  Serial.begin(9600);

  // Initial SHAF Bluetooth
  Serial.println(F("SHAF Bluetooth"));
  Serial.println(F("---------------------------------------------------"));

  randomSeed(micros());

  /* Initialise the module */
  Serial.print(F("Initialising the Bluefruit LE module: "));

  if ( !ble.begin(VERBOSE_MODE) )
  {
    error(F("Couldn't find Bluefruit, make sure it's in CoMmanD mode & check wiring?"));
  }
  Serial.println( F("OK!") );

  /* Perform a factory reset to make sure everything is in a known state */
  Serial.println(F("Performing a factory reset: "));

  
  if (! ble.factoryReset() ){
       error(F("Couldn't factory reset"));
  }

  /* Disable command echo from Bluefruit */
  ble.echo(false);

  Serial.println("Requesting Bluefruit info:");
  /* Print Bluefruit information */
  ble.info();

  // this line is particularly required for Flora, but is a good idea
  // anyways for the super long lines ahead!
  // ble.setInterCharWriteDelay(5); // 5 ms

  /* Change the device name to make it easier to find */
  Serial.println(F("Setting device name to 'SHAF Bluetooth': "));

  if (! ble.sendCommandCheckOK(F("AT+GAPDEVNAME=SHAF Bluetooth")) ) {
    error(F("Could not set device name?"));
  }

 
  /* Service ID should be 1 */
  Serial.println(F("Adding the SHAF-bluetooth Service definition (UUID = 0x180D): "));
  
  success = ble.sendCommandWithIntReply( F("AT+GATTADDSERVICE=UUID=0x180D"), &ServiceId);
  if (! success) {
    error(F("Could not add SHAF bluetooth service"));
  }

  /* Add the CHARACTERISTIC */
  /* Chars ID for Measurement should be 1 */
  Serial.println(F("Adding the cal_err characteristic (UUID = 0x2A37): "));
  // Cal_err id characteristic
  success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A37, PROPERTIES=0x10, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &cal_err_id);
    if (! success) {
    error(F("Could not add call_err characteristic"));
  }
  // Cal_done id characteristic
   Serial.println(F("Adding the call_done characteristic (UUID = 0x2A38): "));
  
  success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A38, PROPERTIES=0x10, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &cal_done_id);
    if (! success) {
    error(F("Could not add cal_done characteristic"));
  }

  // count_correct_rep_id characteristic
   Serial.println(F("Adding the count_correct_rep_id characteristic (UUID = 0x2A39): "));
  
  success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A39, PROPERTIES=0x10, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &count_correct_rep_id);
    if (! success) {
    error(F("Could not add count_correct_id characteristic"));
  }

  // fatigue_flag_id characteristic
   Serial.println(F("Adding the fatigue_flag_id characteristic (UUID = 0x2A3A): "));
  
  success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A3A, PROPERTIES=0x10, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &fatigue_flag_id);
    if (! success) {
    error(F("Could not add fatigue_flag_id characteristics"));
  }

  // timeout_flag_id characteristic
   Serial.println(F("Adding the timeout_flag_id  characteristic (UUID = 0x2A3B): "));
  
  success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A3B, PROPERTIES=0x10, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &timeout_flag_id);
    if (! success) {
    error(F("Could not add timeout_flag_id characteristic"));
  }

  // RECEIVE characteristic
    // calibrate_flag characteristic
    success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A3C, PROPERTIES=0x8, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &calibrate_flag_id);
    if (! success) {
    error(F("Could not add calibrate_flag_id characteristic"));
  }

  // start_flag_id characteristic
    success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A3D, PROPERTIES=0x8, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &start_flag_id);
    if (! success) {
    error(F("Could not add start_flag_id characteristic"));
  }

   // stop_flag_id characteristic
    success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A3E, PROPERTIES=0x8, MIN_LEN=1, MAX_LEN=2, VALUE=0"), &stop_flag_id);
    if (! success) {
    error(F("Could not add stop_flag_id characteristic"));
  }
  /* Add the Body Sensor Location characteristic */
  /* Chars ID for Body should be 2 
  Serial.println(F("Adding the Body Sensor Location characteristic (UUID = 0x2A38): "));
  success = ble.sendCommandWithIntReply( F("AT+GATTADDCHAR=UUID=0x2A38, PROPERTIES=0x02, MIN_LEN=1, VALUE=3"), &hrmLocationCharId);
    if (! success) {
    error(F("Could not add BSL characteristic"));
  } */

  /* Add the Heart Rate Service to the advertising data (needed for Nordic apps to detect the service) */
  //Serial.print(F("Adding Heart Rate Service UUID to the advertising payload: "));
  ble.sendCommandCheckOK( F("AT+GAPSETADVDATA=02-01-06-05-02-0d-18-0a-18") );

  /* Reset the device for the new service setting changes to take effect */
  Serial.print(F("Performing a SW reset (service changes require a reset): "));
  ble.reset();

  Serial.println();

  Serial.println("Waiting to hit the calibration button");

  Timer1.initialize(1000);// set a timer of length 1000 microseconds (or 0.001 sec - or 1kHz)
}

void loop() {
  increase_percentage = 0.00;
  temp_voltage = 0;
  sensorValue = 0;
  start_action = 0;
  
/*
 * This part is for calibration
 */
  calibrate_flag = receive_value (calibrate_flag_id);
  
  if (calibrate_flag == 1 && total_block == 0)
  {
    Timer1.attachInterrupt( timerIsr );
    
    cal_err = Calibrate();
    if (cal_err == 1)
    {
      calibrate_error = 1;
      send_value (cal_err,cal_err_id);
      Serial.print("Calibrate error flag is ");
      Serial.println(calibrate_error);
    }
    else
    {
      int cal_done = 1;
      send_value (cal_done,cal_done_id);
      fatigue_flag = 0;
      do_only_one = 1;   
      block_start = 0;
    }
    Timer1.detachInterrupt();
    calibrate_flag = 0;
    rep_correct_flag = 0;
    total_block = 1;
  }

  if (cal_err == 1)
  {
      total_block = 0;
  }

/*
 * This part is for reps detecting and fatigue detecting
 */
 
  sensorValue = 0;
  
  // Waiting for user to hit the start button
  start_flag = receive_value ( start_flag_id);

  if (start_flag == 1 && block_start == 0)
  {
    temp_voltage = 0;
    
    if (do_only_one == 1) // only need to attach interrupt once
    {
      Serial.println(" Start detecting correct rep and fatigue");
      Timer1.attachInterrupt( timerIsr );
      timeout_count = 0;
      do_only_one = 0;
      rep_correct_flag = 0;
    }
    
    while (rep_correct_flag == 0)
    {    
      
      stop_flag = receive_value ( stop_flag_id);
      if (stop_flag == 1)
      {
        count_correct_rep = 0;
        break;  
        Timer1.detachInterrupt();
      }
      
      if (timeout_flag == 1)
      {
        Serial.println("Timeout error");
        Timer1.detachInterrupt(); 
        send_value (timeout_flag, timeout_flag_id);

        have_two_voltage_flag = 0;
        rep_correct_flag = 2;
        total_block = 1;
        timeout_flag = 0;
        do_only_one = 1;
      }

      while (sensorValue > 35)
      {
        Serial.println(sensorValue);
        if (temp_voltage < sensorValue)
        {
          temp_voltage = sensorValue;
        }
        start_action = 1;
      }
        
      if (temp_voltage > (upper_bound-10))
      {
        Serial.println(" A correct rep is detected");
        rep_correct_flag = 1; 
      }  

      if ((start_action == 1) & (temp_voltage < upper_bound))
      {
        Serial.print(" Your MAX voltage is: ");
        Serial.println(temp_voltage);
        Serial.print(" Not pass the threshold voltage");
        Serial.println(upper_bound);
        start_action = 0;
      }
    }
  //}

  /*
   * What the processor do if a correct rep is detected
   */
  if (rep_correct_flag == 1)
  {
    count_correct_rep = count_correct_rep + 1;
    send_value (count_correct_rep, count_correct_rep_id);
    
    Serial.print("Total correct rep ");
    Serial.println(count_correct_rep);
    
    rep_correct_flag = 0;
    

    if (last_two_flag == 1)
    {
      last_two = last_two - 1;
    }
    
    if (first_rep_flag == 1)
    {
      current_voltage = temp_voltage;
      first_rep_flag = 0;
    }
    else
    {
      previous_voltage = current_voltage;
      current_voltage = temp_voltage;
      have_two_voltage_flag = 1;
    } 
    temp_voltage = 0;
  }

  /*
   * detect fatigue
   */
  if (have_two_voltage_flag == 1)
  {
    total_block = 0;
    stop_block = 0;
    increase_percentage = ((current_voltage - previous_voltage)* 100)/previous_voltage; 
    if (increase_percentage > 20.00)
    {
      fatigue_flag = fatigue_flag + 1;
    }   
  }
  
  if (fatigue_flag == 1)
  {
    Serial.print("  Fatigue at rep: ");
    Serial.println(count_correct_rep);
    Serial.println(" You still can do two more");
    fatigue_flag = 1;
    send_value (fatigue_flag, fatigue_flag_id);

    last_two_flag = 1;
    have_two_voltage_flag = 0;
    first_rep_flag = 1;
    fatigue_flag = 0;
  }

  /*if ((last_two == 0) & (annouce_only_one == 1))
  {
    Serial.println("Good job, you finish");
    Serial.println("Press the calibration button to start over");
  }*/
  start_flag = receive_value ( start_flag_id);

  }

  stop_flag = receive_value ( stop_flag_id);
  if (stop_flag == 1 && stop_block == 0)
  {
    block_start = 1;
    total_block = 0;
    do_only_one = 1;
    stop_block = 1;
    count_correct_rep = 0;
    timeout_count = 0;
    Timer1.detachInterrupt();
  } 
  
}

int Calibrate()
{
  int count = 1;
  int sample = 0;
  float result = 0.00;
  int start = 0;
  
  while (count < 4)
  {
    sample = 0;
    start = 10;
    
    Serial.print("time test ");
    Serial.println(count);
    
    while (start > 0)
    {
      //sensorValue = analogRead(A0);
      Serial.println(sensorValue);
      if (timeout_flag == 1)
      {
        timeout_flag = 0;
        return 1;
      }
      
      if (sensorValue > 35)
      {
        //Serial.println("Sensor value is greater than 50");
        start = start - 1;
      }
    }

//NOTICE: Based line is shifted up to 35 ~ 0.3 mV after adjusting the gain of the sensor  
    while (sensorValue > 20)
    {
      //sensorValue = analogRead(A0);
      Serial.println(sensorValue);
      if (sample < sensorValue)
      {
        sample = sensorValue;
      }
    }
    
    temp[count - 1] = sample;
    
    Serial.print("Upper bound time ");
    Serial.print(count);
    Serial.print(" is: ");
    Serial.println(sample);
    
    count = count + 1;
  }
  
  result = (temp[0] + temp[1] + temp[2]) / 3;
  upper_bound = round(result);
  //upper_bound = 150;
  Serial.print("Final upper bound: ");
  Serial.println(upper_bound);
  
  return 0;
}

void timerIsr()
{
  sensorValue = analogRead(A0);

  if (sensorValue < 35)
  {
    timeout_count = timeout_count + 1;
  }
  else
  {
    timeout_count = 0;
  }

  if (timeout_count == 8000)
  {
    timeout_flag = 1;
  }
}
// Bluetooth sending
void send_value(int n,int32_t id)
{
   ble.print( F("AT+GATTCHAR=") );
   ble.print(id);
   ble.print( F(", ") );
   ble.println(n);
}

// Bluetooth receive
int receive_value(int32_t id)
{
  int result;
   ble.print( F("AT+GATTCHAR=") );
   ble.println(id);
   result = ble.readline_parseInt();
   return result;
}



