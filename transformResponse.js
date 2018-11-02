if(process.argv<2)
	process.exit(0);
process.stdin.on("data",function(data)
{
try
{
data=JSON.parse(data.toString());
eval('var s='+process.argv[2]);
s(data);
}
catch(e)
{
console.log(JSON.stringify({error:data.toString()}));
}
});
