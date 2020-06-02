l = file.list();
for k,v in pairs(l) do
  print("name:"..k..", size:"..v)
end
if file.open("api_key", "r") then
  print(file.read('\n'))
  file.close()
end
if file.open("interval", "r") then
  print(file.read('\n'))
  file.close()
end