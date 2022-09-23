function dna = bin_to_dna(encoded)
    convertedArr = char(zeros(1, (length(encoded)/8)*5));
    nucleotidesArray = ['A' 'C' 'G' 'T'; 'C' 'G' 'T' 'A'; 
                            'G' 'T' 'A' 'C'; 'T' 'A' 'C' 'G'];
    convertedArr_index = 1;
    index = 1;
    for i = 1:2:(length(encoded)-1)
        MSB = encoded(i);
        LSB = encoded(i+1);
        if index == 3
            convertedArr_index = convertedArr_index + 1;
        end
        if index == 4
            convertedArr_index = convertedArr_index - 2;
        end
        if index ~= 4
            if MSB==0 && LSB == 0
                convertedArr(convertedArr_index) = 'A';
            end
            if MSB==0 && LSB == 1
                convertedArr(convertedArr_index) = 'C';
            end
            if MSB==1 && LSB == 0
                convertedArr(convertedArr_index) = 'G';
            end
            if MSB==1 && LSB == 1
                convertedArr(convertedArr_index) = 'T';
            end
        end
        if index == 4 
            for z = 1:1:4
                if MSB == 0 && LSB == 0 
                   convertedArr(convertedArr_index) = nucleotidesArray(1,z);
                   convertedArr(convertedArr_index+2) = nucleotidesArray(1,z); 
                end
                if MSB == 0 && LSB == 1
                   convertedArr(convertedArr_index) = nucleotidesArray(1,z);
                   convertedArr(convertedArr_index+2) = nucleotidesArray(2,z);
                end
                if MSB == 1 && LSB == 0
                    convertedArr(convertedArr_index) = nucleotidesArray(1,z);
                    convertedArr(convertedArr_index+2) = nucleotidesArray(3,z);
                end
                if MSB == 1 && LSB == 1
                    convertedArr(convertedArr_index) = nucleotidesArray(1,z);
                    convertedArr(convertedArr_index+2) = nucleotidesArray(4,z); 
                end
                if ((convertedArr(convertedArr_index-2) ~= convertedArr(convertedArr_index-1)) ...
                    || (convertedArr(convertedArr_index-1) ~= convertedArr(convertedArr_index))) ...
                    && (convertedArr(convertedArr_index+1) ~= convertedArr(convertedArr_index+2))
                    break;
                end
            end
        end  
        convertedArr_index = convertedArr_index + 1;
        index = mod((index + 1),5);
        if index == 0
            index = 1;
            convertedArr_index = convertedArr_index + 2;
        end
    end
    dna = convertedArr;
end