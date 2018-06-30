
function createDropDown(svg, selectOptions)
{
	
alert(selectOptions);

var l=4;

for(i=0;i<selectOptions.length;i++)
{
	if(l<selectOptions[i].length)
	{
		l=selectOptions[i].length
	}
};

l=l*11;

var svg1 = svg.append("g")
  .attr("class","dropdown");
  
var select = svg1.append("g")
			.attr("class","select");
		
			
select.append("rect")
  	.attr("width", l)
	.attr("height", 30)
	.attr("x", 10)
	.attr("y",  10 );
	

select.append("text")
  .attr("x", 15)
	.attr("y",30 )
  .attr("id","axisValues")
	.text( selectOptions[0]);
  
var options = svg1.selectAll(".myBars")
	.data(selectOptions)
	.enter()
	.append("g");
	
options.attr("class", "option")
.on("click", function() { document.getElementById("axisValues").innerHTML=this.getElementsByTagName("text")[0].innerHTML;
  d3.event.stopPropagation();
});

options.append("rect").attr("x", 10)
	.attr("y", function(d,i){ return 40 + i*30})
	.attr("width", l)
	.attr("height", 30);

options.append("text").attr("x", function(d){ return 15})
	.attr("y", function(d,i){ return 60 + i*30})
	.text(function(d){ return d});

	
/*var select = d3.select('body')
  .append('select')
  	.attr('class','select')
    .on('change',onchange)

var options = select
  .selectAll('option')
	.data(data).enter()
	.append('option')
		.text(function (d) { return d; });

function onchange() {
	selectValue = d3.select('select').property('value')
	d3.select('body')
		.append('p')
		.text(selectValue + ' is the last selected option.')
}*/
};