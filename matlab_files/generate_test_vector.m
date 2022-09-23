clear;
clc

num_of_test = 2000;
t=4;
m=6;

fileID = fopen('C:\intelFPGA\17.0\test_vector.txt','w');

for i = 1:num_of_test
    msg = randi([0 1],1,39);
    encoded = encoder(msg, m, t);
    dna = bin_to_dna(encoded);
    damaged_dna = swap_nucleotides(dna);
    binary_message = dna_to_bin(damaged_dna);
    decoded = decoder(binary_message, encoded, m, t);
    val = [zeros(1,39-length(msg)) msg];
    for kk = 1:numel(val)
    fprintf(fileID,'%d',val(kk));
    end
    for kk = 1:numel(dna)
        if(dna(kk)=='A')
            fprintf(fileID,'01000001');
        end
        if(dna(kk)=='C')
            fprintf(fileID,'01000011');
        end
        if(dna(kk)=='G')
            fprintf(fileID,'01000111');
        end
        if(dna(kk)=='T')
            fprintf(fileID,'01010100');
        end
    end
    for kk = 1:numel(damaged_dna)
        if(damaged_dna(kk)=='A')
            fprintf(fileID,'01000001');
        end
        if(damaged_dna(kk)=='C')
            fprintf(fileID,'01000011');
        end
        if(damaged_dna(kk)=='G')
            fprintf(fileID,'01000111');
        end
        if(damaged_dna(kk)=='T')
            fprintf(fileID,'01010100');
        end
    end
    fprintf(fileID,'\r\n');
end

fclose(fileID);
