function outputMatrix = sumMatrices(inputMatrixArray)
% takes a 3D matrix input and returns a 2D matrix where each index
% location is the sum of all the of the input matrix elements at the
% same index.
%
% Example:
% 
%    if
%        inputMatrixArray(1,1,1) == 1
%        inputMatrixArray(1,1,2) == 1
%        inputMatrixArray(1,1,3) == 1
%        inputMatrixArray(1,1,4) == 1
%
%    then
%        outputMatrix(1,1) == 4

for i = 1:10
  for j = 1:10
     outputMatrix(i,j) = inputMatrixArray(i,j,1) + inputMatrixArray(i,j,2) + inputMatrixArray(i,j,3) + inputMatrixArray(i,j,4);
  end
end 