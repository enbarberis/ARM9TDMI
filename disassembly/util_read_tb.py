#!/usr/bin/python3

if __name__ == "__main__":
    fin = open("./instruction_memory_file.asciihex", "r")
    fout= open("./input_tb.hex","w");

    i = 0;
    out_line = "";
    for line in fin:
        out_line = out_line + line.strip('\n')
        if i == 3:
            fout.write("".join(reversed([out_line[j:j+2] for j in range(0,len(out_line),2)])) + "\n")
            out_line = ""
            i = 0
        else:
            i = i+1


    fin.close()
    fout.close()
