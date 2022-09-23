function binary_message = dna_to_bin(dna)
    convertedArr = dna;
    codeArr = zeros(1, (length(convertedArr)/5)*8);
    nucleotidesArray = ['A' 'C' 'G' 'T'; 'C' 'G' 'T' 'A'; 
                            'G' 'T' 'A' 'C'; 'T' 'A' 'C' 'G'];
    codeArr_index = 1;
    index1 = 1;
    i = 1;
    while i < (length(convertedArr))
        nucleotid1 = convertedArr(i);
        if index1 ~= 3 
            if nucleotid1 == 'A'
                codeArr(codeArr_index) = 0;
                codeArr(codeArr_index+1) = 0;
            end
            if nucleotid1 == 'C'
                codeArr(codeArr_index) = 0;
                codeArr(codeArr_index+1) = 1;
            end
            if nucleotid1 == 'G'
                codeArr(codeArr_index) = 1;
                codeArr(codeArr_index+1) = 0;

            end
            if nucleotid1 == 'T'
                codeArr(codeArr_index) = 1;
                codeArr(codeArr_index+1) = 1;
            end
        end
        if index1 == 3 
            nucleotid2 = convertedArr(i+2);
             for q = 1:1:4
                for z = 1:1:4
                    if nucleotid1 == nucleotidesArray(1,z) && ...
                            nucleotid2 == nucleotidesArray(q,z);
                            codeArr(codeArr_index+2) = floor((q-1)/2);
                            codeArr(codeArr_index+3) = mod(q-1,2);
                            break;
                    end
                end
             end
        end
        index1 = mod(index1+1,5);
        i = i + 1;
        if index1 ~= 4 && index1 ~= 0
            codeArr_index = codeArr_index + 2;
        elseif index1 == 0
            codeArr_index = codeArr_index + 4;
            index1 = index1 + 1;
            i = i + 1;
        end
    end
    binary_message = codeArr;
end