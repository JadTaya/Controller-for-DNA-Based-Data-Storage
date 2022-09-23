function damaged_dna = swap_nucleotides(dna)
    damaged_dna = dna;
    nucleotidesArray = ['A' 'C' 'G' 'T'];
    r1 = randi([1 40],1,2);
    r2 = randi([1 4],1,2);
    damaged_dna(r1(1)) = nucleotidesArray(r2(1));
    damaged_dna(r1(2)) = nucleotidesArray(r2(2));
end