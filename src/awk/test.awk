BEGIN { 
  srand(1234567891)
  X="eg_" ARGV[1]; if(X in FUNCTAB) @X()
  for(X in SYMTAB)
    if(X ~ /[a-z]/) 
     print("? " X) }
