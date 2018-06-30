function draw(data)
{
		var selectOptions = Object.keys(data[1]);
		
		//removes column indicating time component
		selectOptions = selectOptions.splice(1,selectOptions.length);
		
		var objX = {"Maximum Temperature" :"MAX_TEMP_DATA","Minimum Temperature":"MIN_TEMP_DATA","Rainfall":"RAINFALL_DATA","Cyclones\\Depressions":"SEVERE_WEATHER_DATA","Minimum Temp Anamoly":"MIN_TEMP_ANAM", "Maximum Temp Anamoly": "MAX_TEMP_ANAM"}
		var objY = {"Minimum Temperature":"MIN_TEMP_DATA","Maximum Temperature" :"MAX_TEMP_DATA","Rainfall":"RAINFALL_DATA","Cyclones\\Depressions":"SEVERE_WEATHER_DATA","Minimum Temp Anamoly":"MIN_TEMP_ANAM", "Maximum Temp Anamoly": "MAX_TEMP_ANAM"}
		var objSize = {"Rainfall":"RAINFALL_DATA","Maximum Temperature" :"MAX_TEMP_DATA","Minimum Temperature":"MIN_TEMP_DATA","Cyclones\\Depressions":"SEVERE_WEATHER_DATA","Minimum Temp Anamoly":"MIN_TEMP_ANAM", "Maximum Temp Anamoly": "MAX_TEMP_ANAM"}
		var objColor = {"Month":"MONTH","Season":  "SEASON" };
		
		xOptions = Object.keys(objX);
		yOptions = Object.keys(objY);
		sizeOptions = Object.keys(objSize);
		colorOptions = Object.keys(objColor);
		
			
		var body = d3.select("body");
		
		// X-axis Variable
		var span = body.append("span")
						.text("Select X-Axis Variable");
		var xInput = body.append("select")
							.attr("id","xSelect")
							.on("change",xChange)
						  .selectAll("option")
							.data(xOptions)
							.enter()
						  .append("option")
							.attr("value",function(d){ return d;})
							.text(function(d) { return d;});
		var span = body.append("span")
						.text("\u00A0");
		
		var span = body.append("span")
						.text("Select size Variable");
		var sizeInput = body.append("select")
							.attr("id","sizeSelect")
							.on("change",sizeChange)
						  .selectAll("option")
							.data(sizeOptions)
							.enter()
						  .append("option")
							.attr("value",function(d){ return d;})
							.text(function(d) { return d;});
		body.append("br");
		body.append("br");
		var span = body.append("span")
						.text("Select Y-Axis Variable");
		var yInput = body.append("select")
							.attr("id","ySelect")
							.on("change",yChange)
						  .selectAll("option")
							.data(yOptions)
							.enter()
						  .append("option")
							.attr("value",function(d){ return d})
							.text(function(d) { return d;});
		var span = body.append("span")
						.text("\u00A0");
							
		var span = body.append("span")
						.text("Select color Variable");
		var sizeInput = body.append("select")
							.attr("id","colorSelect")
							.on("change",colorChange)
						  .selectAll("option")
							.data(colorOptions)
							.enter()
						  .append("option")
							.attr("value",function(d){ return d})
							.text(function(d) { return d;});
							
		body.append("br");
		
		var margin = {
						top : 50,
						right : 50,
						bottom : 50,
						left : 50
					 }
		
		var svgHeight = 550;
		var svgWidth = 900;
		
		var buttonHeight = 30, buttonWidth = 50;
		
	    var svg = dimple.newSvg("body",svgWidth, svgHeight);
		
		var frame = 1500;
	
					
		var button = svg.append("g")
							.attr("id","button")
							.classed("Pause",true)
							.attr("transform", "translate(" +(margin.left *3.5) + "," +
											(margin.top) + ")");
					button.append("rect")
							.attr("height",buttonHeight)
							.attr("width",buttonWidth)
							.attr("fill","lightgrey")
							.on("mouseover",function(){d3.select(this).attr("fill","grey")})
							.on("mouseout",function(){d3.select(this).attr("fill","lightgrey")})
							.style("stroke","black");
					button.append("text")
							.attr("x",(buttonWidth/2))
							.attr("y",buttonHeight/2)
							.style("font-size", "12px")
							.attr("text-anchor","middle")
							.attr("alignment-baseline","central")
							.text("Pause");
					button.on("click", onClick);
		
		var timeVar = "YEAR";
				
		var dropdown_x = d3.select("#xSelect")
		var dropdown_y = d3.select("#ySelect");
		var dropdown_size = d3.select("#sizeSelect")
		var dropdown_color = d3.select("#colorSelect")
		
		var xVar = objX[dropdown_x.node().options[dropdown_x.node().selectedIndex].value];
	    var yVar = objY[dropdown_y.node().options[dropdown_y.node().selectedIndex].value];
		var sizeVar = objSize[dropdown_size.node().options[dropdown_size.node().selectedIndex].value];
		var colorVar = objColor[dropdown_color.node().options[dropdown_color.node().selectedIndex].value];
		
		var filterColumn = "INTERVAL";

		var filterData = dimple.filterData(data, filterColumn, colorVar);
		
		var chart = new dimple.chart(svg, filterData);
		
		chart.setBounds(margin.left + buttonWidth, margin.top + buttonHeight * 1.2, svgWidth - margin.left - margin.right - buttonWidth,svgHeight - margin.top - margin.bottom - buttonHeight);
			
		var xData = filterData.map(function(d) { return d[xVar] ; } );
		var yData = filterData.map(function(d) { return d[yVar] ; } );
		var sizeData = filterData.map(function(d) { return d[sizeVar];});
		
					 
		var xData_l = Math.min.apply(null, xData);
		var xData_u = Math.max.apply(null, xData);
	
		var yData_l = Math.min.apply(null,yData);
		var yData_u = Math.max.apply(null,yData);
	
		var sizeData_l = Math.min.apply(null,sizeData);
		var sizeData_u = Math.max.apply(null, sizeData);
	
		var xData_r = xData_u - xData_l
		var yData_r = yData_u - yData_l
			
		var x_axis = chart.addMeasureAxis("x", xVar)
		x_axis.overrideMin  = Math.floor(xData_l);
		x_axis.overrideMax = Math.ceil(xData_u);
		x_axis.ticks = 15;
		x_axis.title = dropdown_x.node().options[dropdown_x.node().selectedIndex].value;
	
		var y_axis = chart.addMeasureAxis("y", yVar);
		y_axis.overrideMin = Math.floor(yData_l);
		y_axis.overrideMax = Math.floor(yData_u);
		y_axis.ticks = 10;
		y_axis.title = dropdown_y.node().options[dropdown_y.node().selectedIndex].value;
	
		var size_axis = chart.addMeasureAxis("z", sizeVar);
		size_axis.overrideMin = Math.floor(sizeData_l);
		size_axis.overrideMax = Math.ceil(sizeData_u);	
		size_axis.title = dropdown_size.node().options[dropdown_size.node().selectedIndex].value;
			
		
		var story = chart.setStoryboard(timeVar, function (d) 
		{
	        console.log(d.frameValue);
        });
			
		series = chart.addSeries("MONTH", dimple.plot.bubble);
	
		chart.addLegend(svgWidth-(margin.left * 8), margin.top, 300, buttonHeight);
    	chart.draw();
		d3.selectAll("circle").style("stroke-width", 2);
			 
		story.frameDuration = frame;  
		
		
		function xChange ()
		{
			var value = objX[this.value];
			
			var xData = data.map(function(d) { return d[value] ; } );
			var xData_l = Math.min.apply(null,xData);
			var xData_u = Math.max.apply(null,xData);
			var xData_r = xData_u - xData_l;
			
			x_axis.measure = value;
			x_axis.overrideMin = Math.floor(xData_l);
			x_axis.overrideMax = Math.floor(xData_u);
			x_axis.ticks = 15;
			x_axis.title = this.value;
			
            		
			chart.draw();
		}
		
		function yChange ()
		{
			var value = objY[this.value];
			
			var yData = data.map(function(d) { return d[value] ; } );
			var yData_l = Math.min.apply(null,yData);
			var yData_u = Math.max.apply(null,yData);
			
			y_axis.measure = value;
			y_axis.overrideMin = Math.floor(yData_l);
			y_axis.overrideMax = Math.floor(yData_u);
			y_axis.ticks = 10;
			y_axis.title = this.value;
            		
			chart.draw();
			
		}
		
		function sizeChange ()
		{
			var value = objSize[this.value];
			
			var sizeData = data.map(function(d) { return d[value] ; } );
			var sizeData_l = Math.min.apply(null,sizeData);
			var sizeData_u = Math.max.apply(null,sizeData);
			
			size_axis.measure = value;
			size_axis.overrideMin = Math.floor(sizeData_l);
			size_axis.overrideMax = Math.floor(sizeData_u);
			size_axis.ticks = 10;
			size_axis.title = this.value;
            		
			chart.draw();
			
		}
		
		function colorChange ()
		{
			var value = objColor[this.value];
			filterColumn = "INTERVAL";
			
			chart.data = dimple.filterData(data, filterColumn, value);
			chart.draw();
		}
		
		function onClick() 
		{
			if(button.classed("Pause"))
			{
				button.classed("Pause",false);
				updateButton("Play");
				story.pauseAnimation();
			}
			else if(button.classed("Play"))
			{
				button.classed("Play",false);
				updateButton("Pause");
				story.startAnimation();
			}
		}
	
		function updateButton(newClass)
		{
			button.classed(newClass,true)
			d3.select("#button text")
				.transition()
				.text(newClass);
		}
		
	
}