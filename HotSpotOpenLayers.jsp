<!DOCTYPE html>
<html>
  <head>
    <title>Custom Animation</title>
    <!-- Original link -->    
    <!-- <link rel="stylesheet" href="https://openlayers.org/en/v4.6.5/css/ol.css" type="text/css"> -->
    <!-- The line below is only needed for old environments like Internet Explorer and Android 4.x -->
<!--     <script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=requestAnimationFrame,Element.prototype.classList,URL"></script> -->
    <!-- <script src="https://openlayers.org/en/v4.6.5/build/ol.js"></script> -->
    
<!-- 이 링크로는 코드 중에서 에러 발생    
	<script src="https://cdn.jsdelivr.net/npm/ol@v7.1.0/dist/ol.js"></script>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@v7.1.0/ol.css">  
  -->
    
	<!-- 이런식으로 해당 소스를 로컬에 저장해서 하는 방식도 가능
	     아래와 같은 식으로는 다음과 같은 에러 발생한다.
	     Uncaught TypeError: Cannot read properties of undefined (reading 'setStyle')
	     vectorContext.setStyle(style);  
	 -->
<%-- 	<link res="stylesheet" href="${pageContext.request.contextPath}/resources/openLayersV6_15_1/ol.css">
	<script src="${pageContext.request.contextPath}/resources/openLayersV6_15_1/ol.js"></script> 
 --%>
   
   <!-- 이런식으로 로컬에 OpenLayers관련 css, js를 저장한 후 아래와 같이 사용해도 가능  -->
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/openLayersV4_6_5/ol.css">
   <script src="${pageContext.request.contextPath}/resources/openLayersV4_6_5/ol.js"></script>
   
<%--    
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/openLayersV6_15_1/ol.css"> 
   <script src="${pageContext.request.contextPath}/resources/openLayersV6_15_1/ol.js"></script>   
    --%>
   
  </head>   
  <body> 
    <div id="myMap" style="width: 1600px; height: 900px;"class="map"></div>
    <script>
/*     
    var map = new ol.Map({
    	  layers: ○,
    	  target: ○,
    	  controls: ○,
    	  view: ○
    	});

Basic Concepts에 대해서는 아래 링크 참조
https://openlayers.org/en/v4.6.5/doc/tutorials/concepts.html
https://openlayers.org/en/v4.6.5/doc/tutorials/
*/

	//새로 이동할 위, 경도 위치 설정    
	var pnt = new ol.geom.Point([128.420173920421, 35.6468668083004]).transform('EPSG:4326', 'EPSG:3857'); 
	var mPos = pnt.getCoordinates();

      var map = new ol.Map({
        layers: [
          new ol.layer.Tile({
            source: new ol.source.OSM({
              wrapX: false
            })
          })
        ],  
        controls: ol.control.defaults({
          attributionOptions: {
            collapsible: false
          }
        }),
        target: 'myMap',
        view: new ol.View({
          center: mPos,      
          zoom: 13
        })  
      });

      var source = new ol.source.Vector({
        wrapX: false
      });
      
      var vector = new ol.layer.Vector({  
        source: source
      });
      
      //아래 코드 주석처리하면 빨간색 안의 작은 파란색 원이 보이지 않는다. 빨간색 원만 보인다. 
      map.addLayer(vector);   

	  ////////// Custom Animation 샘플 코드 참조 ///////////////////////
      function addRandomFeature() {
        var x = Math.random() * 360 - 180;
        var y = Math.random() * 180 - 90;
        
        //console.log("####### x", x);
        //console.log("####### y", y);
        
        //128.420173920421, 35.6468668083004
        //특정 지역에 대한 값으로 고정
        x = 128.319173920421; //-12.0653515314441;                               
        y = 35.6468668083004; //18.027796101489926;    
        
        var x1 = 128.420173920421;
        var y1 = 35.6768668083004;     
                 
        var geom = new ol.geom.Point(ol.proj.transform([x, y],
            'EPSG:4326', 'EPSG:3857'));
        var feature = new ol.Feature(geom);      
        //var feature = new ol.Feature(mPos);
        
        //아래 함수 실행시 source.on('addfeature', function(e) {});가 callback으로 호출된다.
        source.addFeature(feature);
        
        //아래와 같이 하면 2개 지점에 대해 물결 파장 만들수 있다.
        var geom2 = new ol.geom.Point(ol.proj.transform([x1, y1], 'EPSG:4326', 'EPSG:3857'));
        var feature2 = new ol.Feature(geom2);
        
        //아래 함수 실행시 source.on('addfeature', function(e) {});가 callback으로 호출된다.
        source.addFeature(feature2); 
        
      } //addRandomFeature

      
      var duration = 3000;  // 빨간색 원이 사라지는 시간          
      function flash(feature) {
        var start = new Date().getTime();  
        var listenerKey;

        function animate(event) {
          //console.log("####### event", event);
        	
          var vectorContext = event.vectorContext;
          var frameState = event.frameState;
          var flashGeom = feature.getGeometry().clone();
          //var elapsed = frameState.time - start; //원본
          var elapsed = frameState.time - start; 
          //var elapsed = frameState.time - frameState.time; //작은 원 하나.
          var elapsedRatio = elapsed / duration;        
          // radius will be 5 at start and 30 at end.  
          // + 5의 의미 : 빨간색 원이 맨 처음 시작할 원의 크기. 이 값이 크면 작은데서 큰 원으로가 아니라 제법 큰 원에서 더 큰 원으로 크지는 형태가 된다.
          // * 25의 의미 : 빨간색 원의 최고 크기 사이즈를 의미
          var radius = ol.easing.easeOut(elapsedRatio) * 55 + 5;  /* * 25 + 5 */  //여기가 원본  
          //var radius = ol.easing.easeOut(elapsedRatio) * 10 + 10;  
          //var radius = ol.easing.easeOut(elapsedRatio) * 7; // 설치지점에 대한 작은 원이 깜빡이는 형태. 큰 원으로 animation 되는 효과 없음. 자그마한 작은 원이 깜빡이는 형태        
          var opacity = ol.easing.easeOut(1 - elapsedRatio);

          
          /* 빨강색 원 모양(원 테두리만 그림) */ 
          var style = new ol.style.Style({
            image: new ol.style.Circle({
              radius: radius,
              snapToPixel: false,
              stroke: new ol.style.Stroke({
                color: 'rgba(255, 0, 0, ' + opacity + ')',  
                //color: 'rgba(0, 0, 200, ' + opacity + ')',  
                width: 2.25 + opacity  // 0.25 + opacity width는 빨간색 선의 굵기                 
              })
            })
          });
  
  
 		/* 빨강색 원 모양(원 안을 채움)  
 		  var style = new ol.style.Style({
 			  image: new ol.style.Circle({
 				  radius: radius,
 				  fill: new ol.style.Fill({  
 					  color: 'rgba(255, 0, 0, ' + 0.5 * opacity + ')',
 				  })
 			  })
 		  });  
         */ 
 
          vectorContext.setStyle(style);  
          vectorContext.drawGeometry(flashGeom);
          if (elapsed > duration) {
            ol.Observable.unByKey(listenerKey);
            return;
          }
          // tell OpenLayers to continue postcompose animation
          map.render();
        }
        listenerKey = map.on('postcompose', animate);
      } //flash
      

      source.on('addfeature', function(e) {
    	  	console.log("source-addfeature event: ", e.feature);
    	  	
        	flash(e.feature);
      });

      /* 원을 표시하는 시간 간격 */   
      window.setInterval(addRandomFeature, 2000);
      
      ////////// Earthquakes Clusters 샘플 코드 참조 ///////////////////////
  	  //var lon = 128.457173920421;      
	  //var lat = 35.6768668083004;    

	  //핫 스팟 원을 채울 색상(주황색)
      var circleFillorange = new ol.style.Fill({
    	  color: 'rgba(255, 153, 0, 0.4)'
      });
	  
	  //핫 스팟 원을 채울 색상(red) 
	  var circleFillred = new ol.style.Fill({
		  color: 'rgba(255, 0, 0, 0.25)'
	  }); 

	  //핫 스팟으로 사용할 원 추가 
      addCircle(128.370173920421, 35.6368668083004, 1700, circleFillred);  // lon, lat
      addCircle(128.399973920421, 35.6708668083004, 1000, circleFillorange);  // lon, lat 
      
      function addCircle(lon, lat, circleSize, fillColor){  
    	  var feature = new ol.Feature({
    		  // ol.geom.Circle()의 두 번째 매개인자인 숫자의 크기가 원의 크기임. 클수록 원이 크짐
    		  geometry: new ol.geom.Circle(ol.proj.fromLonLat([lon, lat]), circleSize),       
    		  name : '수충격 위험지역'
    	  });
    	  
    	  var vectorSource = new ol.source.Vector({
    		 features: [feature] 
    	  });
    	  
    	  var circleLayer = new ol.layer.Vector({  
    		 source: vectorSource,
    		 style: [
    			 new ol.style.Style({ 
    				 /*****  
    				 stroke: new ol.style.Stroke({  
    					 //color: 'red',
    					 color: 'rgba(255, 0, 0, 0.25)',
    					 width: 1
    				 }),
    				 *****/
    				 /*******
    				 fill: new ol.style.Fill({  
    					 color: 'rgba(255, 0, 0, 0.25)'
    				 })
    			 	****/
    			 	fill: fillColor
    			 })
    		 ]
    	  });
    	  
    	  //지도에 circle 레이어 추가
    	  map.addLayer(circleLayer);
      } //addCircle
      
      
      // Earthquakes Heatmap(밀도 핫 스팟) 샘플 소스 참조  ///////////////////////////////////////////
      var arrLonLat = [ [128.4550595, 35.6861580], 
    	  				[128.4509894, 35.6545807], //
    	  				[128.4328773, 35.6340736], 
    	  				[128.4009267, 35.7096262], 
    	  				[128.3362115, 35.6555729], 
    	  				[128.4145617, 35.6122377], 
    	  				[128.4478620, 35.6569162], 
    	  				[128.4586845, 35.6647638], //
    	  				[128.4456525, 35.6292994], 
    	  				[128.4596525, 35.6282994]
      				  ];
      
      let arrPoint = new Array();   
      let arrPos = new Array();  
      let name;
      // Heatmap 형태로 지도상에 핫 스팟을 표시할 데이터를 담고 있는 객체
      let heatmap_data = {type: "FeatureCollection"};
      // Heatmap 형태로 핫 스팟을 표시할때 지도상에 표실 될 위치(위경도 값)을 담을 배열(객체) 
      let arrHeatmapFeatures = new Array();

	  console.log("####### arrLonLat.length : ", arrLonLat.length);
	  console.log("####### arrLonLat[0].length : ", arrLonLat[0].length);
	  console.log("####### arrLonLat[0] : ", arrLonLat[0]);        
	  
	  //let delay = 0;   
      for(let i=0; i<arrLonLat.length; i++){      
    	  //delay += 1000;
    	  //setTimeout(function(){
    		  console.log("####### iii: ", i);      
    		  console.log("####### 777 : ", arrLonLat[i]);   
    		  
        	  arrPoint[i] = new ol.geom.Point(arrLonLat[i]).transform('EPSG:4326', 'EPSG:3857');
        	  arrPos[i] = arrPoint[i].getCoordinates();
        	  name = "sample " + (i + 1);
        	  arrHeatmapFeatures[i] = {
        			  type: "Feature",
        			  geometry: {
        				  type: "Point",
        				  coordinates: arrPos[i]
        			  },
        			  properties: { title: "HeatmapPts", id: 999, name: name}
        	  };
    	  //}, delay);  
      } //for
     
     
      arrHeatmapFeatures.push({
			type: "Feature",
			geometry: {
				type: "Point",
				coordinates: arrPos[9]
			},
			properties: { title: "HeatmapPts", id: 999, name: "sample 10"}
		});
      
      arrHeatmapFeatures.push({
			type: "Feature",
			geometry: {
				type: "Point",
				coordinates: arrPos[9]
			},
			properties: { title: "HeatmapPts", id: 999, name: "sample 11"}
		});
      
      heatmap_data.features = arrHeatmapFeatures;
    	  
/*****      
		heatmap_data = {
		  type: "FeatureCollection",
		  features: [
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [716015.7709315167, 941114.3812981017]
		        coordinates: arrPos[0]
		      },
		      properties: { title: "HeatmapPts", id: 111, name: "sample 1" }
		    },
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [686213.47091037, 1093486.3776117]
		        coordinates: arrPos[1]
		      },
		      properties: { title: "HeatmapPts", id: 222, name: "sample 2" }
		    },
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [687067.04391223, 1094462.7275206]
		        coordinates: arrPos[2]
		      },
		      properties: { title: "HeatmapPts", id: 333, name: "sample 3" }
		    },
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [715175.426212967, 940887.9894195743]
		        coordinates: arrPos[3]
		      },
		      properties: { title: "HeatmapPts", id: 444, name: "sample 4" }
		    },
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [715199.78960381, 940877.6180225]
		        coordinates: arrPos[4]
		      },
		      properties: { title: "HeatmapPts", id: 555, name: "sample 5" }
		    },
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [687214.60645801, 1094362.868384]
		        coordinates: arrPos[5]
		      },
		      properties: { title: "HeatmapPts", id: 666, name: "sample 6" }
		    },
		    {
		      type: "Feature",
		      geometry: {
		        type: "Point",
		        //coordinates: [614971.473, 1218630.894]
		        coordinates: arrPos[6]
		      },
		      properties: { title: "HeatmapPts", id: 777, name: "sample 7" }
		    },
		    {
			      type: "Feature",
			      geometry: {
			        type: "Point",
			        // coordinates: [620197.188, 1222790.136]
			        coordinates: arrPos[7]
			      },
			      properties: { title: "HeatmapPts", id: 888, name: "sample 8" }
			},
			{
				type: "Feature",
				geometry: {
					type: "Point",
					coordinates: arrPos[8]
				},
				properties: { title: "HeatmapPts", id: 999, name: "sample 9"}
			},
			{
				type: "Feature",
				geometry: {
					type: "Point",
					coordinates: arrPos[9]
				},
				properties: { title: "HeatmapPts", id: 999, name: "sample 10"}
			},
			{
				type: "Feature",
				geometry: {
					type: "Point",
					coordinates: arrPos[9]
				},
				properties: { title: "HeatmapPts", id: 999, name: "sample 10"}
			},
			{
				type: "Feature",
				geometry: {
					type: "Point",
					coordinates: arrPos[9]
				},
				properties: { title: "HeatmapPts", id: 999, name: "sample 10"}
			}
		  ]
		};      
      **********************/
      
		var heatfeature = new ol.source.Vector({  
			  features: new ol.format.GeoJSON().readFeatures(heatmap_data, { 
			    dataProjection: "EPSG:32643",
			    featureProjection: "EPSG:32643"
			  })
			});

    	//아래 이벤트는 현재 안됨(추후 삭제)
		heatfeature.on('singleclick', function(evt){ 
			console.log("evt: ", evt); 
		});
		
		var blur = 60;
		var radius = 45;
		//var shadow = 150;

		var heatmaplayer = new ol.layer.Heatmap({
		  title: "HeatMap",
		  source: heatfeature,
		  blur: blur,                 // Blur size in pixels. Default is 15.
		  radius: radius,             // Radius size in pixels. Default is 8.
		  //shadow: shadow,             // Shadow size in pixels. Default is 250. 
		  opacity: 1.0,
		  weight: function (feature) {
		    return 10;
		  }
		});
		
		//아래 이벤트는 현재 안됨(추후 삭제)
		heatmaplayer.on('singleclick', function(evt){  
			console.log("heatmaplayer - evt: ", evt);  
		}, this);
		
		map.addLayer(heatmaplayer);       

    </script>
  </body>
</html>



