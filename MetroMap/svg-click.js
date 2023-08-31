//加载时执行
function setGroupClickFunction(){
    document.documentElement.style.webkitUserSelect='none';
    document.documentElement.style.webkitTouchCallout='none';
    
    var svg = document.getElementsByTagName("svg");
    for(var i=0; i<svg.length; i++){
        svg[i].setAttribute("onclick","resetMap()");
    }
    
    var lineColors = '{';
    var groups = document.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.substr(0, 2)=="N-"){
            //站点名字
            groups[i].setAttribute("onclick","showStation(this, 1)");
            groups[i].setAttribute("style","-webkit-tap-highlight-color:transparent;");
        }else if(groups[i].id.substr(0, 2)=="S-"){
            //站点标记
            groups[i].setAttribute("onclick","showStation(this, 1)");
            groups[i].setAttribute("style","-webkit-tap-highlight-color:transparent;");
        }else if(groups[i].id.substr(0, 2)=="L-"){
            //线路
            groups[i].setAttribute("onclick","findSelectedLine(this, 1)");
            groups[i].setAttribute("style","-webkit-tap-highlight-color:transparent;");
            var stroke = groups[i].getAttribute("stroke");
            if(stroke==null) {
                var path = groups[i].getElementsByTagName("path");
                if(path!=null && path.length>0) for(var j=0; j<path.length; j++){
                    if(path[j].getAttribute("opacity")==null || path[j].getAttribute("opacity")==1){
                        stroke = path[j].getAttribute("stroke");
                        break;
                    }
                }
            }
            if(stroke!=null){
                var lineCode = groups[i].id.substr(2).split("-")[0];
                if(lineColors=="{") lineColors = lineColors+"\""+lineCode+"\":\""+stroke+"\"";
                else lineColors = lineColors+",\""+lineCode+"\":\""+stroke+"\"";
            }
        }
    }
    return lineColors+"}";
};

function console(str){
    var timer = setInterval(function () {
                            window.webkit.messageHandlers.console.postMessage({body: str});clearInterval(timer);
     },500);
};



function swtichColors(isDarkMode){
    var svg = document.getElementsByTagName("svg");
    for(var i=0; i<svg.length; i++){
        svg[i].setAttribute("darkMode",isDarkMode);
    }
    
    var mask = document.getElementById("mode_switch_rect_bg");
    if(mask){
        if(isDarkMode==1) mask.setAttribute("fill","#2E2E30");
        else mask.setAttribute("fill","white");
    }
//    var delements = document.getElementsByClassName("mode_switch");
//    if(delements) for(var j=0; j<delements.length; j++){
//        var ele = delements[j];
//        if(ele.getAttribute("fill").length>0 && ele.getAttribute("fill_dark").length>0 && ele.getAttribute("fill_light").length>0){
//            ele.setAttribute("fill",ele.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
//        }else if(ele.getAttribute("stroke").length>0 && ele.getAttribute("stroke_dark").length>0 && ele.getAttribute("stroke_light").length>0){
//            ele.setAttribute("stroke",ele.getAttribute(isDarkMode==1?"stroke_dark":"stroke_light"));
//        }
//    }
    
    
    var rects = document.getElementsByClassName("mode_switch_rect");
    var lines = document.getElementsByClassName("mode_switch_line");
    var signs = document.getElementsByClassName("mode_switch_station_sign");
    var sign_fills = document.getElementsByClassName("mode_switch_station_fill_sign");
    var sign_strokes = document.getElementsByClassName("mode_switch_station_stroke_sign");
    var texts = document.getElementsByClassName("mode_switch_station_text");
    var terrains = document.getElementsByClassName("mode_switch_terrain");
    var terrain_rivers = document.getElementsByClassName("mode_switch_terrain_river");

    if(rects) for(var j=0; j<rects.length; j++){
        var rect = rects[j];
        rect.setAttribute("fill",rect.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
    }
    if(lines) for(var j=0; j<lines.length; j++) {
        var line = lines[j];
        line.setAttribute("stroke",line.getAttribute(isDarkMode==1?"stroke_dark":"stroke_light"));
    }
    if(signs) for(var j=0; j<signs.length; j++) {
        var sign = signs[j];
        sign.setAttribute("fill",sign.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
        sign.setAttribute("stroke",sign.getAttribute(isDarkMode==1?"stroke_dark":"stroke_light"));
    }
    if(sign_fills) for(var j=0; j<sign_fills.length; j++) {
        var sign = sign_fills[j];
        sign.setAttribute("fill",sign.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
    }
    if(sign_strokes) for(var j=0; j<sign_strokes.length; j++) {
        var sign = sign_strokes[j];
        sign.setAttribute("stroke",sign.getAttribute(isDarkMode==1?"stroke_dark":"stroke_light"));
    }
    if(texts) for(var j=0; j<texts.length; j++) {
        var text = texts[j];
        text.setAttribute("fill",text.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
        if(text.getAttribute("stroke") && text.getAttribute("stroke").length>0) text.setAttribute("stroke",text.getAttribute(isDarkMode==1?"stroke_dark":"stroke_light"));
    }
    if(terrains) for(var j=0; j<terrains.length; j++) {
        var terrain = terrains[j];
        terrain.setAttribute("fill",terrain.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
    }
    if(terrain_rivers) for(var j=0; j<terrain_rivers.length; j++) {
        var terrain_river = terrain_rivers[j];
        terrain_river.setAttribute("stroke",terrain_river.getAttribute(isDarkMode==1?"stroke_dark":"stroke_light"));
    }
    

        var logo_texts = document.getElementsByClassName("mode_switch_logo_text");
        if(logo_texts) for(var j=0; j<logo_texts.length; j++){
            var ele = logo_texts[j];
            ele.setAttribute("fill",ele.getAttribute(isDarkMode==1?"fill_dark":"fill_light"));
            ele.setAttribute("opacity",ele.getAttribute(isDarkMode==1?"opacity_dark":"opacity_light"));
        }
        var logo_backs = document.getElementsByClassName("mode_switch_logo_back");
        if(logo_backs) for(var j=0; j<logo_backs.length; j++){
            var ele = logo_backs[j];
            ele.setAttribute("fill-opacity",ele.getAttribute(isDarkMode==1?"fill-opacity_dark":"fill-opacity_light"));
        }
};


//初始化颜色
function initColorParams(isDarkMode){
    var svg = document.getElementsByTagName("svg");
    for(var i=0; i<svg.length; i++){
        svg[i].setAttribute("darkMode",isDarkMode);
    }
    
    //背景
    var rects = svg[0].getElementsByTagName("rect");
    if(rects && rects.length>0) for(var i=0; i<rects.length; i++){
        if(rects[i].getAttribute("fill")=="#FFFFFF"){
            rects[i].classList.add("mode_switch_rect");
            rects[i].setAttribute("fill_dark","#131415");
            rects[i].setAttribute("fill_light","#FFFFFF");
            if(isDarkMode==1) rects[i].setAttribute("fill","#131415");
            break;
        }
    }
                      
    //在建
    var buildingLine = document.getElementById("在建线路");
    if(buildingLine){
        //线路
        var buildingPathes = buildingLine.getElementsByTagName("path");
        if(buildingPathes) for(var j=0; j<buildingPathes.length; j++){
            var path = buildingPathes[j];
            if(path.getAttribute("stroke")=="#F2F2F2"){
                path.classList.add("mode_switch_line");
                path.classList.add("mode_switch");
                path.setAttribute("stroke_dark","#1B1B1B");
                path.setAttribute("stroke_light","#F2F2F2");
                if(isDarkMode==1) path.setAttribute("stroke","#1B1B1B");
            }
        }
        //非换乘站点
        var stationGroups = buildingLine.getElementsByTagName("g");
        if(stationGroups) for(var j=0; j<stationGroups.length; j++){
            var group = stationGroups[j];
            if(group.id.substr(0,2)=="S-"){
                group.classList.add("mode_switch_station_sign");
                group.classList.add("mode_switch");
                group.setAttribute("stroke_dark","#1F1F1F");
                group.setAttribute("stroke_light","#FFFFFF");
                if(isDarkMode==1) group.setAttribute("stroke","#1F1F1F");
                group.setAttribute("fill_dark","#323232");
                group.setAttribute("fill_light","#FFFFFF");
                if(isDarkMode==1) group.setAttribute("fill","#323232");
            }else if(group.id.substr(0,2)=="N-"){
                var stationText = group.getElementsByTagName("text");
                if(stationText) for(var k=0; k<stationText.length; k++){
                    var text = stationText[k];
                    text.classList.add("mode_switch_station_text");
                    text.classList.add("mode_switch");
                    text.setAttribute("fill_dark",text.getAttribute("fill")=="#9B9B9B"?"#89898A":"#D0D0D0");
                    text.setAttribute("fill_light",text.getAttribute("fill")=="#9B9B9B"?"#9B9B9B":"#4A4A4A");
                    if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
                }
            }else if(group.id.substr(0,2)=="O-"){
                var stationText = group.getElementsByTagName("text");
                if(stationText) for(var k=0; k<stationText.length; k++){
                    var text = stationText[k];
                    text.classList.add("mode_switch_station_text");
                    text.classList.add("mode_switch");
                    text.setAttribute("fill_dark","#131415");
                    text.setAttribute("fill_light","#FFFFFF");
                    if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
                    text.setAttribute("stroke_dark","#131415");
                    text.setAttribute("stroke_light","#FFFFFF");
                    if(isDarkMode==1) text.setAttribute("stroke",text.getAttribute("stroke_dark"));
                }
                var circles = group.getElementsByTagName("circle");
                if(circles) for(var k=0; k<circles.length; k++){
                    var circle = circles[k];
                    circle.classList.add("mode_switch_station_text");
                    circle.classList.add("mode_switch");
                    circle.setAttribute("fill_dark","#1B1B1B");
                    circle.setAttribute("fill_light","#F2F2F2");
                    if(isDarkMode==1) circle.setAttribute("fill",circle.getAttribute("fill_dark"));
                }
            }
        }
    }

    var allLine = document.getElementById("Metro");
//    if(allLine) initStationColorParams(allLine, false, isDarkMode);
    if(allLine){
        //非换乘站点
        var stationGroups = allLine.getElementsByTagName("g");
        if(stationGroups) for(var j=0; j<stationGroups.length; j++){
            var group = stationGroups[j];
            if(group.id.substr(0,2)=="S-"){
                group.classList.add("mode_switch_station_sign");
                group.classList.add("mode_switch");
                group.setAttribute("stroke_dark","#131415");
                group.setAttribute("stroke_light","#FFFFFF");
                if(isDarkMode==1) group.setAttribute("stroke","#131415");
//                group.setAttribute("fill_dark","#000000");
//                group.setAttribute("fill_light","#FFFFFF");
//                if(isDarkMode==1) group.setAttribute("fill","#000000");
            }else if(group.id.substr(0,2)=="N-"){
                var stationText = group.getElementsByTagName("text");
                if(stationText) for(var k=0; k<stationText.length; k++){
                    var text = stationText[k];
                    text.classList.add("mode_switch_station_text");
                    text.classList.add("mode_switch");
                    text.setAttribute("fill_dark",text.getAttribute("fill")=="#9B9B9B"?"#89898A":"#D0D0D0");
                    text.setAttribute("fill_light",text.getAttribute("fill"));
                    if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
                }
            }else if(group.id.substr(0,2)=="O-"){
                var stationText = group.getElementsByTagName("text");
                if(stationText) for(var k=0; k<stationText.length; k++){
                    var text = stationText[k];
                    text.classList.add("mode_switch_station_text");
                    text.classList.add("mode_switch");
                    text.setAttribute("fill_dark","#131415");
                    text.setAttribute("fill_light","#FFFFFF");
                    if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
                    text.setAttribute("stroke_dark","#131415");
                    text.setAttribute("stroke_light","#FFFFFF");
                    if(isDarkMode==1) text.setAttribute("stroke",text.getAttribute("stroke_dark"));
                }
            }
        }
    }
                  
                              
    var transfor = document.getElementById("换乘");
    if(transfor){
        var spathes = transfor.getElementsByTagName("path");
        if(spathes) for(var j=0; j<spathes.length; j++){
            if(spathes[j].getAttribute("fill")=="#F2F2F2"){
                spathes[j].classList.add("mode_switch_station_fill_sign");
                spathes[j].classList.add("mode_switch");
                spathes[j].setAttribute("fill_dark","#131415");
                spathes[j].setAttribute("fill_light","#F2F2F2");
                if(isDarkMode==1) spathes[j].setAttribute("fill","#131415");
            }else if(spathes[j].getAttribute("fill")=="#FFFFFF"){
                spathes[j].classList.add("mode_switch_station_fill_sign");
                spathes[j].classList.add("mode_switch");
                spathes[j].setAttribute("fill_dark","#1B1B1B");
                spathes[j].setAttribute("fill_light","#FFFFFF");
                if(isDarkMode==1) spathes[j].setAttribute("fill","#1B1B1B");
            }
            if(spathes[j].getAttribute("stroke")=="#000000"){
                spathes[j].classList.add("mode_switch_station_stroke_sign");
                spathes[j].classList.add("mode_switch");
                spathes[j].setAttribute("stroke_dark","#2E2E30");
                spathes[j].setAttribute("stroke_light","#000000");
                if(isDarkMode==1) spathes[j].setAttribute("stroke","#2E2E30");
            }else if(spathes[j].getAttribute("stroke")=="#FFFFFF"){
                spathes[j].classList.add("mode_switch_station_stroke_sign");
                spathes[j].classList.add("mode_switch");
                spathes[j].setAttribute("stroke_dark","#131415");
                spathes[j].setAttribute("stroke_light","#FFFFFF");
                if(isDarkMode==1) spathes[j].setAttribute("stroke","#131415");
            }
        }
        var transfor_rects = transfor.getElementsByTagName("rect");
        if(transfor_rects) for(var j=0; j<transfor_rects.length; j++){
            if(transfor_rects[j].getAttribute("fill")=="#FFFFFF"){
                transfor_rects[j].classList.add("mode_switch_station_fill_sign");
                transfor_rects[j].classList.add("mode_switch");
                transfor_rects[j].setAttribute("fill_dark","#1B1B1B");
                transfor_rects[j].setAttribute("fill_light","#FFFFFF");
                if(isDarkMode==1) transfor_rects[j].setAttribute("fill","#1B1B1B");
            }else if(transfor_rects[j].getAttribute("fill")=="#F2F2F2"){
                transfor_rects[j].classList.add("mode_switch_station_fill_sign");
                transfor_rects[j].classList.add("mode_switch");
                transfor_rects[j].setAttribute("fill_dark","#131415");
                transfor_rects[j].setAttribute("fill_light","#F2F2F2");
                if(isDarkMode==1) transfor_rects[j].setAttribute("fill","#131415");
            }
            if(transfor_rects[j].getAttribute("stroke")=="#000000"){
                transfor_rects[j].classList.add("mode_switch_station_stroke_sign");
                transfor_rects[j].classList.add("mode_switch");
                transfor_rects[j].setAttribute("stroke_dark","#2E2E30");
                transfor_rects[j].setAttribute("stroke_light","#000000");
                if(isDarkMode==1) transfor_rects[j].setAttribute("stroke","#2E2E30");
            }else if(transfor_rects[j].getAttribute("stroke")=="#FFFFFF"){
                transfor_rects[j].classList.add("mode_switch_station_stroke_sign");
                transfor_rects[j].classList.add("mode_switch");
                transfor_rects[j].setAttribute("stroke_dark","#131415");
                transfor_rects[j].setAttribute("stroke_light","#FFFFFF");
                if(isDarkMode==1) transfor_rects[j].setAttribute("stroke","#131415");
            }
        }
        var transforGroups = transfor.getElementsByTagName("g");
        if(transforGroups && transforGroups.length>0) for(var j=0; j<transforGroups.length; j++){
            var group = transforGroups[j];
            if(group.id.substr(0,2)=="N-" || group.id=="出站换乘提示"){
                var stationText = group.getElementsByTagName("text");
                if(stationText) for(var k=0; k<stationText.length; k++){
                    var text = stationText[k];
                    text.classList.add("mode_switch_station_text");
                    text.classList.add("mode_switch");
                    if(text.getAttribute("fill")=="#9B9B9B") text.setAttribute("fill_dark","#89898A");
                    else if(text.getAttribute("fill")=="#FFFFFF") text.setAttribute("fill_dark","#131415");
                    else text.setAttribute("fill_dark","#D0D0D0");
                    text.setAttribute("fill_light",text.getAttribute("fill"));
                    if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
                }
            }
        }
    }
    
    //图示
    var logo_text_en = document.getElementById("city_name_en");
    if(logo_text_en){
        logo_text_en.classList.add("mode_switch_logo_text");
        logo_text_en.setAttribute("fill_dark","#FFFFFF");
        logo_text_en.setAttribute("opacity_dark","0.5");
        logo_text_en.setAttribute("fill_light","#7F8A93");
        logo_text_en.setAttribute("opacity_light","1");
        if(isDarkMode==1) logo_text_en.setAttribute("fill",logo_text_en.getAttribute("fill_dark"));
        if(isDarkMode==1) logo_text_en.setAttribute("opacity",logo_text_en.getAttribute("opacity_dark"));
    }
    
    var logo_text_ch = document.getElementById("city_name_ch");
    if(logo_text_ch){
        logo_text_ch.classList.add("mode_switch_logo_text");
        logo_text_ch.setAttribute("fill_dark","#FFFFFF");
        logo_text_ch.setAttribute("opacity_dark","0.8");
        logo_text_ch.setAttribute("fill_light","#001627");
        logo_text_ch.setAttribute("opacity_light","1");
        if(isDarkMode==1) logo_text_ch.setAttribute("fill",logo_text_ch.getAttribute("fill_dark"));
        if(isDarkMode==1) logo_text_ch.setAttribute("opacity",logo_text_ch.getAttribute("opacity_dark"));
    }
    var logo_text = document.getElementById("线路示例");
    if(logo_text){
        var stationText = logo_text.getElementsByTagName("text");
        if(stationText) for(var k=0; k<stationText.length; k++){
            var text = stationText[k];
            text.classList.add("mode_switch_logo_text");
            text.setAttribute("fill_dark","#FFFFFF");
            text.setAttribute("opacity_dark","0.5");
            text.setAttribute("fill_light","#9B9B9B");
            text.setAttribute("opacity_light","1");
            if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
            if(isDarkMode==1) text.setAttribute("opacity",text.getAttribute("opacity_dark"));
        }
        var lineStatus = logo_text.getElementsByTagName("rect");
        if(lineStatus) for(var k=0; k<lineStatus.length; k++){
            var lineSta = lineStatus[k];
            if(lineSta.getAttribute("fill")=="#000000"){
                lineSta.classList.add("mode_switch_line");
                lineSta.setAttribute("fill_dark","#FFFFFF");
                lineSta.setAttribute("fill_light","#000000");
                if(isDarkMode==1) lineSta.setAttribute("fill",lineSta.getAttribute("fill_dark"));
            }
        }
    }
    var logoback = document.getElementById("logoback");
    if(logoback){
        var useEles = logoback.getElementsByTagName("use");
        if(useEles) for(var k=0; k<useEles.length; k++){
            var useEle = useEles[k];
            if(useEle.getAttribute("fill-opacity")=="0"){
                useEle.classList.add("mode_switch_logo_back");
                useEle.setAttribute("fill-opacity_light","0");
                useEle.setAttribute("fill-opacity_dark","1");
                if(isDarkMode==1) useEle.setAttribute("fill-opacity",useEle.getAttribute("fill-opacity_dark"));
            }
        }
    }
                              
    //地形
    var terrain_river = document.getElementById("河流");
    if(terrain_river) {
        terrain_river.classList.add("mode_switch_terrain_river");
        terrain_river.classList.add("mode_switch");
        terrain_river.setAttribute("stroke_dark","#162035");
        terrain_river.setAttribute("stroke_light","#D3F1FF");
        if(isDarkMode==1) terrain_river.setAttribute("stroke",terrain_river.getAttribute("stroke_dark"));
    }
    var terrain_lake = document.getElementById("湖泊");
    if(terrain_lake) {
        terrain_lake.classList.add("mode_switch_terrain");
        terrain_lake.classList.add("mode_switch");
        terrain_lake.setAttribute("fill_dark","#162035");
        terrain_lake.setAttribute("fill_light","#D3F1FF");
        if(isDarkMode==1) terrain_lake.setAttribute("fill",terrain_lake.getAttribute("fill_dark"));
    }
    var terrain_island = document.getElementById("岛屿");
    if(terrain_island) {
        terrain_island.classList.add("mode_switch_terrain");
        terrain_island.classList.add("mode_switch");
        terrain_island.setAttribute("fill_dark","#131415");
        terrain_island.setAttribute("fill_light","#FFFFFF");
        if(isDarkMode==1) terrain_island.setAttribute("fill",terrain_island.getAttribute("fill_dark"));
    }
};
    
                                                    
function initStationColorParams(element, changeCircle, isDarkMode){
    //非换乘站点
    var stationGroups = element.getElementsByTagName("g");
    if(stationGroups) for(var j=0; j<stationGroups.length; j++){
        var group = stationGroups[j];
        if(group.id.substr(0,2)=="S-"){
            group.classList.add("mode_switch_station_sign");
            group.classList.add("mode_switch");
            group.setAttribute("stroke_dark","#000000");
            group.setAttribute("stroke_light","#FFFFFF");
            if(isDarkMode==1) group.setAttribute("stroke","#000000");
            group.setAttribute("fill_dark","#000000");
            group.setAttribute("fill_light","#FFFFFF");
            if(isDarkMode==1) group.setAttribute("fill","#000000");
        }else if(group.id.substr(0,2)=="N-"){
            var stationText = group.getElementsByTagName("text");
            if(stationText) for(var k=0; k<stationText.length; k++){
                var text = stationText[k];
                text.classList.add("mode_switch_station_text");
                text.classList.add("mode_switch");
                text.setAttribute("fill_dark",text.getAttribute("fill")=="#9B9B9B"?"#89898A":"#D0D0D0");
                text.setAttribute("fill_light",text.getAttribute("fill")=="#9B9B9B"?"#9B9B9B":"#4A4A4A");
                if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
            }
        }else if(group.id.substr(0,2)=="O-"){
            var stationText = group.getElementsByTagName("text");
            if(stationText) for(var k=0; k<stationText.length; k++){
                var text = stationText[k];
                text.classList.add("mode_switch_station_text");
                text.classList.add("mode_switch");
                text.setAttribute("fill_dark","#131415");
                text.setAttribute("fill_light","#FFFFFF");
                if(isDarkMode==1) text.setAttribute("fill",text.getAttribute("fill_dark"));
                text.setAttribute("stroke_dark","#131415");
                text.setAttribute("stroke_light","#FFFFFF");
                if(isDarkMode==1) text.setAttribute("stroke",text.getAttribute("stroke_dark"));
            }
            if(changeCircle){
                var circles = group.getElementsByTagName("circle");
                if(circles) for(var k=0; k<circles.length; k++){
                    var circle = circles[k];
                    circle.classList.add("mode_switch_station_text");
                    circle.classList.add("mode_switch");
                    circle.setAttribute("fill_dark","#1B1B1B");
                    circle.setAttribute("fill_light","#F2F2F2");
                    if(isDarkMode==1) circle.setAttribute("fill",circle.getAttribute("fill_dark"));
                }
            }
        }
    }
}



function showLocateStation(stationName){
    var groups = document.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.substr(0, 2)=="S-" && groups[i].id.substr(2)==stationName){
            var boxWidth = groups[i].getBBox().width;
            var boxHeight = groups[i].getBBox().height;
            var svg = document.getElementsByTagName("svg");
//            var scale = svg[0].getAttribute("svg-scale");
            var mscale = svg[0].getAttribute("init-scale");
            var width = svg[0].getAttribute("frame-width");
            var height = svg[0].getAttribute("frame-height");
            var location = getTranslate(groups[i]);
            location[0] = location[0]+boxWidth/2;
            location[1] = location[1]+boxHeight/2;
            
//            window.webkit.messageHandlers.showLocateStation.postMessage({stationName: stationName, location:[location[0]*mscale,location[1]*mscale], mscale:mscale});
            return {stationName: stationName, location:[location[0]*mscale,location[1]*mscale], mscale:mscale};
        }
    }
};
                              
function initStationColorParams(element, changeCircle){
    
}

function showAppointStation(stationName){
    var groups = document.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.substr(0, 2)=="S-" && groups[i].id.substr(2)==stationName){
            return showStation(groups[i], 0);
        }
    }
}

//展示站点弹出框
function showStation(station, type){
    if(!checkInGroup(station.parentElement, "Metro") && !checkInGroup(station.parentElement, "换乘")) return;
    if(type==1){
        var ev = window.event || arguments.callee.caller.arguments[0];
        if (window.event) ev.cancelBubble = true;
        else ev.stopPropagation();
    }
    //展示路线时不弹出
    var routeData = document.getElementsByClassName("route_show_temp");
    if(routeData!=null && routeData.length>0) return;
    
    showLines();
    removeRoutes(0);

    var stationId = "S-"+station.id.substr(2);
    station = document.getElementById(stationId);
    if(!checkInGroup(station.parentElement, "Metro") && !checkInGroup(station.parentElement, "换乘")) return;
    var boxWidth = station.getBBox().width;
    var boxHeight = station.getBBox().height;
    var svg = document.getElementsByTagName("svg");
//    var scale = svg[0].getAttribute("svg-scale");
    var mscale = svg[0].getAttribute("init-scale");
    var width = svg[0].getAttribute("frame-width");
    var height = svg[0].getAttribute("frame-height");
    var location = getTranslate(station);
    location[0] = location[0]+boxWidth/2;
    location[1] = location[1]+boxHeight/2;
    
    if(station.id.split("-").length<2) return;
    var stationName = station.id.split("-")[1];//.split(".")[0];
    if(type==0){
        return {stationName: stationName, location:[location[0]*mscale,location[1]*mscale], mscale:mscale};
    }else{
        window.webkit.messageHandlers.showStation.postMessage({stationName: stationName, location:[location[0]*mscale,location[1]*mscale], mscale:mscale});
    }
};


function checkInGroup(element, groupId){
    if(element.id == groupId) return true;
    else if(element.parentElement!=null){
        return checkInGroup(element.parentElement, groupId);
    }
    else return false;
}


function showAppointLine(lineCode){
    var groups = document.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.substr(0, 2)=="L-" && checkInGroup(groups[i], "Metro") && groups[i].id.substr(2).split("-")[0]==lineCode){
            findSelectedLine(groups[i], 0);
            return;
        }
    }
};

function findSelectedLine(line, type){
    if(!checkInGroup(line.parentElement, "Metro")) return;
    if(type==1){
        var ev = window.event || arguments.callee.caller.arguments[0];
        if (window.event) ev.cancelBubble = true;
        else ev.stopPropagation();
    }
    //展示路线时不弹出
    var routeData = document.getElementsByClassName("route_show_temp");
    if(routeData!=null && routeData.length>0) return;
    
    var lines = new Array();
    var lineId = line.id.substr(2).split("-")[0];
    var groups = document.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.substr(0, 2)=="L-" && checkInGroup(groups[i].parentElement, "Metro") && groups[i].id.substr(2).split("-")[0]==lineId){
            lines.push(groups[i]);
        }
    }
    
    var svg = document.getElementsByTagName("svg");
    var mscale = svg[0].getAttribute("init-scale");
    
    var minX = 99999;
    var minY = 99999;
    var maxX = -1;
    var maxY = -1;
    
    for(var i=0; i<lines.length; i++){
        var sline = lines[i];
        var boxWidth = sline.getBBox().width;
        var boxHeight = sline.getBBox().height;
        var location = getTranslate(sline);
        if(location[0]*mscale < minX) minX = location[0]*mscale;
        if(location[1]*mscale < minY) minY = location[1]*mscale;
        if(location[0]*mscale+boxWidth*mscale > maxX) maxX = location[0]*mscale+boxWidth*mscale;
        if(location[1]*mscale+boxHeight*mscale > maxY) maxY = location[1]*mscale+boxHeight*mscale;
    }
    
    
//    window.webkit.messageHandlers.showLine.postMessage({lineCode: line.id, rect:[location[0]*mscale, location[1]*mscale, boxWidth*mscale, boxHeight*mscale], mscale:mscale});
    window.webkit.messageHandlers.showLine.postMessage({lineCode: line.id, rect:[minX, minY, maxX-minX, maxY-minY], mscale:mscale});
};


function showLine(lineCode,stationNames){
    var lcode = lineCode.split("-")[1].split(".")[0];
    var svg = document.getElementsByTagName("svg");
    var namespace = 'http://www.w3.org/2000/svg';
    var metro = document.getElementById("Metro");
//    var line = metro.getElementById(lineCode);
    var lines = new Array();
    var groups = metro.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.split("-").length<2) continue;
        var gcode = groups[i].id.split("-")[1].split(".")[0];
        var prix =groups[i].id.substr(0,2).toUpperCase();
        if(prix=="L-" && gcode==lcode){
            lines.push(groups[i]);
        }
    }
    
    if(lines==null || lines.length<=0) return;
    
    if(document.getElementById("line_mask")==null) addMaskView("line_show_temp");

    //线路
    var line_show = document.createElementNS(namespace,'g');
    line_show.setAttribute("id","line_show"+i);
    line_show.classList.add("line_show_temp");
    line_show.setAttribute("transform",metro.getAttribute("transform"));
    for(var i=0; i<lines.length; i++){
        var lineClone = lines[i].cloneNode(true);
        var sgroups = lineClone.getElementsByTagName("g");
        for(var j=0; j<sgroups.length; j++){
            if(sgroups[j].id.length<2) continue;
            var prix =sgroups[j].id.substr(0,2).toUpperCase();
            if(prix=="N-" && sgroups[j].getAttribute("opacity")<1) sgroups[j].setAttribute("opacity","1");
        }
        line_show.appendChild(lineClone);
    }
    metro.parentElement.appendChild(line_show);
    
    //换乘站
    var snames = stationNames.split(",");
    var transfor = document.getElementById("换乘");
    var transfor_station_show = document.createElementNS(namespace,'g');
    transfor_station_show.setAttribute("id","transfor_station_show"+i);
    transfor_station_show.classList.add("line_show_temp");
    transfor_station_show.setAttribute("transform",transfor.getAttribute("transform"));
    for(var i=0; i<snames.length; i++){
        var sname = snames[i];
        var stationNameSign = document.getElementById("N-"+sname);
        if(stationNameSign!=null && checkInGroup(stationNameSign,"换乘")){
            var stationNameSignClone = stationNameSign.cloneNode(true);
            stationNameSignClone.setAttribute("opacity","1");
            transfor_station_show.appendChild(stationNameSignClone);
        }
        var stationSign = document.getElementById("S-"+sname);
        if(stationSign!=null && checkInGroup(stationSign,"换乘"))
            transfor_station_show.appendChild(stationSign.cloneNode(true));
    }
    transfor.parentElement.appendChild(transfor_station_show);
}

function resetMap(){
    //展示路线时不弹出
    var routeData = document.getElementsByClassName("route_show_temp");
    if(routeData!=null && routeData.length>0) return;
    
    showLines();
    removeRoutes(0);
    window.webkit.messageHandlers.removeStation.postMessage({});
    window.webkit.messageHandlers.showAllLines.postMessage({});
};

//展示所有线路
function showLines(){
    var tempData = document.getElementsByClassName("line_show_temp");
    if(tempData!=null) while(tempData.length>0){
        tempData[0].parentNode.removeChild(tempData[0]);
    }
};


function getCrossPath(pointX, pointY){
    var path = "M"+(pointX-100)+","+pointY+" L"+(pointX+100)+","+pointY+" M"+pointX+","+(pointY-100)+" L"+pointX+","+(pointY+100)
        +" M"+(pointX-100)+","+(pointY-100)+" L"+(pointX+100)+","+(pointY+100) +" M"+(pointX+100)+","+(pointY-100)+" L"+(pointX-100)+","+(pointY+100);
    return path;
};

function getStationCenterPoint(stationName){
    var stationId = "S-"+stationName;
    station = document.getElementById(stationId);
    if(station==null) station = document.getElementById(stationId.split(".")[0]);
    if(station==null) return;
    if(!checkInGroup(station.parentElement, "Metro") && !checkInGroup(station.parentElement, "换乘")) return;
    var boxWidth = station.getBBox().width;
    var boxHeight = station.getBBox().height;
    var svg = document.getElementsByTagName("svg");
//    var scale = svg[0].getAttribute("svg-scale");
    var mscale = svg[0].getAttribute("init-scale");
    var width = svg[0].getAttribute("frame-width");
    var height = svg[0].getAttribute("frame-height");
    var location = getTranslate(station);
    location[0] = location[0]+boxWidth/2;
    location[1] = location[1]+boxHeight/2;
    location[0] = location[0]*mscale;
    location[1] = location[1]*mscale;
    return location;
}


function showRoute(lineCode, stationNames, lineColor, checkDirection){
    var stations = stationNames.split(",");
    if(stations.length<2) return;
    var startLocation = getStationCenterPoint(stations[0]);
    var endLocation = getStationCenterPoint(stations[stations.length-1]);
    
    var nextLocation = getStationCenterPoint(stations[1]);
    
    if(document.getElementById("line_mask")==null) addMaskView("route_show_temp");
    
    //展示线路
    var rect = null;
    var success = false;
    if(checkDirection==0){
        success = showRouteSegment(lineCode, startLocation[0], startLocation[1], endLocation[0], endLocation[1], false, 0, 0);
    }else if(checkDirection==1){
        success = showRouteSegment(lineCode, startLocation[0], startLocation[1], endLocation[0], endLocation[1], nextLocation?true:false, nextLocation?nextLocation[0]:0, nextLocation?nextLocation[1]:0);
    }
    if(!success){
        rect = showRouteStations(lineCode, stationNames, lineColor, true);
    }else{
        rect = showRouteStations(lineCode, stationNames, lineColor, false);
    }

    if(rect!=null){
        var svg = document.getElementsByTagName("svg");
        var mscale = svg[0].getAttribute("init-scale");
        return {rect:[rect[0]*mscale, rect[1]*mscale, rect[2]*mscale, rect[3]*mscale], mscale:mscale};
    }
    return {};
}

function addMaskView(className){
    var namespace = 'http://www.w3.org/2000/svg';
    var svg = document.getElementsByTagName("svg");
    var metro = document.getElementById("Metro");
    var mask = document.createElementNS(namespace,'rect');
    var width = svg[0].getAttribute("svg-width");
    var height = svg[0].getAttribute("svg-height");
    mask.setAttribute("id","line_mask");
    mask.classList.add(className);
    
    mask.classList.add("mode_switch_rect");
    mask.setAttribute("fill_dark","#2E2E30");
    mask.setAttribute("fill_light","white");
    if(svg[0].getAttribute("darkMode")=="1") mask.setAttribute("fill","#2E2E30");
    else mask.setAttribute("fill","white");
    
    mask.setAttribute("fill-opacity",0.95);
    mask.setAttribute("width",width);
    mask.setAttribute("height",height);
    mask.setAttribute("x",0);
    mask.setAttribute("y",0);
    metro.parentElement.appendChild(mask);
    
//    var mapDist = document.getElementById("地形");
//    if(mapDist!=null){
//        var mapDistClone = mapDist.cloneNode(true);
//        mapDistClone.classList.add(className);
//        metro.parentElement.appendChild(mapDistClone);
//    }
    var mapDesc = document.getElementById("图示");
    if(mapDesc!=null){
        var mapDescClone = mapDesc.cloneNode(true);
        mapDescClone.classList.add(className);
        metro.parentElement.appendChild(mapDescClone);
    }
}


function showRouteStations(lineCode,stationNames,lineColor,showRoute){
    var namespace = 'http://www.w3.org/2000/svg';
    var svg = document.getElementsByTagName("svg");
    var mscale = svg[0].getAttribute("init-scale");
    var snames = stationNames.split(",");
    var metro = document.getElementById("Metro");
    var transfor = document.getElementById("换乘");
    
    var line = null;
    var linePath = null;
    var groups = document.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.indexOf("L-")==0 && checkInGroup(groups[i], "Metro") && groups[i].id.split("-")[1].split(".")[0]==lineCode.split("-")[1].split(".")[0]){
            line = groups[i];
            var pathes = line.getElementsByTagName("path");
            for(var j=0; j<pathes.length; j++) if(pathes[j].id.indexOf("P-")==0){
                linePath = pathes[j];
                break;
            }
            break;
        }
    }
    var route_station_show = document.createElementNS(namespace,'g');
    route_station_show.setAttribute("id","route_station_show"+lineCode);
    route_station_show.classList.add("route_show_temp");
    route_station_show.setAttribute("transform",metro.getAttribute("transform"));
    
    var route_transfor_show = document.createElementNS(namespace,'g');
    route_transfor_show.setAttribute("id","route_transfor_show"+lineCode);
    route_transfor_show.classList.add("route_show_temp");
    if(transfor && transfor!=null) route_transfor_show.setAttribute("transform",transfor.getAttribute("transform"));

    var locations = new Array();
    for(var i=0; i<snames.length; i++){
        var sname = snames[i];
        var stationNameSign = document.getElementById("N-"+sname);
        if(stationNameSign==null) stationNameSign = document.getElementById("N-"+sname.split(".")[0]);
        if(stationNameSign!=null){
            if(checkInGroup(stationNameSign,"换乘")){
                var stationNameSignClone = stationNameSign.cloneNode(true);
                stationNameSignClone.setAttribute("opacity","1");
                route_transfor_show.appendChild(stationNameSignClone);
            }else if(checkInGroup(stationNameSign,"Metro")){
                var stationNameSignClone = stationNameSign.cloneNode(true);
                stationNameSignClone.setAttribute("opacity","1");
                var slocation = getTranslateFromElement(stationNameSign, metro);
                stationNameSignClone.setAttribute("transform","translate("+slocation[0]+","+slocation[1]+")");
                route_station_show.appendChild(stationNameSignClone);
            }
        }
            
        var stationSign = document.getElementById("S-"+sname);
        if(stationSign==null) stationSign = document.getElementById("S-"+sname.split(".")[0]);
        if(stationSign!=null){
            if(checkInGroup(stationSign,"换乘")){
                route_transfor_show.appendChild(stationSign.cloneNode(true));
            }else if(checkInGroup(stationSign,"Metro")){
                var stationSignClone = stationSign.cloneNode(true);
                var slocation = getTranslateFromElement(stationSign, metro);
                stationSignClone.setAttribute("transform","translate("+slocation[0]+","+slocation[1]+")");
                route_station_show.appendChild(stationSignClone);
                line = stationSign.parentElement;
            }

            var boxWidth = stationSign.getBBox().width;
            var boxHeight = stationSign.getBBox().height;
            var slocation = getTranslateFromElement(stationSign, metro.parentElement);
            slocation[0] = (slocation[0]+boxWidth/2);
            slocation[1] = (slocation[1]+boxHeight/2);
            locations.push(slocation);
        }
    }

    if(showRoute){
        var rpath = "";
        for(var i=0; i<locations.length; i++){
            var slocation = locations[i];
            if(i==0) rpath = rpath + "M"+slocation[0]+","+slocation[1]+" ";
            else rpath = rpath + "L"+slocation[0]+","+slocation[1]+" ";
        }
        var routeGroup = document.createElementNS(namespace,'g');
        routeGroup.setAttribute("id","route_result_group"+lineCode);
        routeGroup.classList.add("route_show_temp");
        if(linePath!=null) routeGroup.appendChild(createPath(namespace,linePath,rpath));
        else{
                            
                            var newPath = document.createElementNS(namespace,'path');
                            newPath.setAttribute("d", rpath);
                            newPath.setAttribute("stroke",lineColor);
                            newPath.setAttribute("stroke-width","4");
                            newPath.setAttribute("stroke-linecap","round");
                            newPath.setAttribute("stroke-linejoin","round");
                            routeGroup.appendChild(newPath);
        }
        metro.parentElement.appendChild(routeGroup);
    }
    metro.parentElement.appendChild(route_station_show);
    if(transfor && transfor!=null) transfor.parentElement.appendChild(route_transfor_show);

    var rectMinX = -1;
    var rectMinY = -1;
    var rectMaxX = -1;
    var rectMaxY = -1;
    for(var i=0; i<locations.length; i++){
        var slocation = locations[i];
        if(rectMinX<0 || rectMinX>slocation[0]) rectMinX = slocation[0];
        if(rectMinY<0 || rectMinY>slocation[1]) rectMinY = slocation[1];
        if(rectMaxX<slocation[0]) rectMaxX = slocation[0];
        if(rectMaxY<slocation[1]) rectMaxY = slocation[1];
    }
    var rect = new Array();
    rect.push(rectMinX);
    rect.push(rectMinY);
    rect.push(rectMaxX);
    rect.push(rectMaxY);
                            
    return rect;
    
}

function showRouteSegment(lineCode, startX, startY, endX, endY, checkDirection, nextX, nextY){
    var lcode = lineCode.split("-")[1].split(".")[0];
    var svg = document.getElementsByTagName("svg");
    var mscale = svg[0].getAttribute("init-scale");
    var namespace = 'http://www.w3.org/2000/svg';
    startX = startX/mscale;
    startY = startY/mscale;
    endX = endX/mscale;
    endY = endY/mscale;
    nextX = nextX/mscale;
    nextY = nextY/mscale;
    
    var metro = document.getElementById("Metro");
    var paths = new Array();
    var groups = metro.getElementsByTagName("g");
    for (var i=0;i<groups.length;i++){
        if(groups[i].id.split("-").length<2) continue;
        var gcode = groups[i].id.split("-")[1].split(".")[0];
        var prix =groups[i].id.substr(0,2).toUpperCase();
        
        //匹配path
        if(prix=="L-" && gcode==lcode){
            var gpaths = groups[i].getElementsByTagName("path");
            for(var j=0; j<gpaths.length; j++){
                if(gpaths[j].id.split("-").length<2) continue;
                var pcode = gpaths[j].id.split("-")[1].split(".")[0];
                var pprix =gpaths[j].id.substr(0,2).toUpperCase();
                if(pprix=="P-" && pcode==lcode){
                    paths.push(gpaths[j]);
                }
            }
        }
    }
    
    //TODO 分支路线
    var line;
    var linePath;
    var lineLocation;
    var ins1;
    var ins2;
    var l = paths.length;
    var next_x = 0;
    var next_y = 0;
    for(var i=0; i<l; i++){
        var path = paths[i].getAttribute("d");
        var pid = paths[i].id;
        var location = getTranslate(paths[i]);
        var start_x = startX-location[0];
        var start_y = startY-location[1];
        var end_x = endX-location[0];
        var end_y = endY-location[1];
        var path1 = getCrossPath(start_x, start_y);
        var path2 = getCrossPath(end_x, end_y);
        var ints1 = Snap.path.intersection(path, path1);
        var ints2 = Snap.path.intersection(path, path2);
        if(!ints1 || !ints2 || ints1.length<=0 || ints2.length<=0) continue;
        next_x = nextX-location[0];
        next_y = nextY-location[1];
        var tempIns1 = getNearestPoint(ints1, start_x, start_y);
        var tempIns2 = getNearestPoint(ints2, end_x, end_y);
        if(tempIns1!=null && tempIns2!=null){
            linePath = path;
            line = paths[i];
            lineLocation = location;
            ins1 = tempIns1;
            ins2 = tempIns2;
        }
    }
    if(ins1==null || ins2==null) return false;
   
    //是否为反向
    var reverse = false;
    if(ins1.segment1 > ins2.segment1) reverse=true;
    else if(ins1.segment1 == ins2.segment1 && ins1.t1>ins2.t1) reverse = true;
    
    var pathSegments = Snap.parsePathString(linePath);
    
    var segment1 = pathSegments[ins1.segment1-1];
    var startSegment = "M"+segment1[1]+","+segment1[2] + " " + parseStringByArray(pathSegments[ins1.segment1], " ");
    var segment2 = pathSegments[ins2.segment1-1];
    var endSegment = "M"+segment2[1]+","+segment2[2] + " " + parseStringByArray(pathSegments[ins2.segment1], " ");
                            
    var loc1 = 0;
    var loc2 = 0;
    var loc3 = 0;
    var lastPoint = [0,0];
    //线段全用贝塞尔曲线表示
    var cubicSegments = Snap.parsePathString(Snap.path.toCubic(linePath));
    if(cubicSegments==null || cubicSegments.length<=0) return false;
    for(var i=0; i<cubicSegments.length; i++){
        if(i==0) continue;
        var seg = cubicSegments[i];
        var prevSeg = cubicSegments[i-1];
        if(seg.lengh<3 || prevSeg.length<3) continue;
        
        //上一个片段最后两位为起始坐标，加上当前片段
        var segpath = "M" + prevSeg[prevSeg.length-2] + "," + prevSeg[prevSeg.length-1] + parseStringByArray(seg," ");
        //片段长度
        var segmentLength = Snap.path.getTotalLength(segpath);
        
        var tt1 = ins1.t1;
        if(ins1.t1>0.5) tt1 = 1-ins1.t1;
        tt1 = Math.pow(tt1/(tt1*0.2+0.6),2);
        if(ins1.t1>0.5) tt1 = 1-tt1;
        var tt2 = ins2.t1;
        if(ins2.t1>0.5) tt2 = 1-ins2.t1;
        tt2 = Math.pow(tt2/(tt2*0.2+0.6),2);
        if(ins2.t1>0.5) tt2 = 1-tt2;
                       
        if(ins1.segment1==i) loc1 = loc1+segmentLength*tt1;
        else if(ins1.segment1>i) loc1 = loc1 + segmentLength;
        if(ins2.segment1==i) loc2 = loc2+segmentLength*tt2;
        else if(ins2.segment1>i) loc2 = loc2 + segmentLength;
        loc3 = loc3 + segmentLength;
    }
    var linePathLength = Snap.path.getTotalLength(cubicSegments);
    var resultPath = Snap.path.getSubpath(cubicSegments, loc1, loc2);
    if(loc1>loc2) resultPath = Snap.path.getSubpath(cubicSegments, loc2, loc1);
    
    var defaultLine = true;
    if(checkDirection){
                       //loct1为第一个点，loct2为第二个点
                       var loct1 = (loc1>loc2)?loc2:loc1;
                       var loct2 = (loct1==loc1)?loc2:loc1;
                       //终点和第二个站点的坐标一致
                       if((nextX == endX && nextY == endY) || (next_x<=0 || next_y<=0)){
                            //点间距离大于整条线段的1/2则取反方向
                            if(loct2-loct1 > linePathLength/2){
                               defaultLine = false;
                               var resultPath1 = Snap.path.getSubpath(cubicSegments, 0, loct1);
                               var resultPath2 = Snap.path.getSubpath(cubicSegments, loct2, linePathLength);
                               
                                var routeGroup = document.createElementNS(namespace,'g');
                                routeGroup.setAttribute("id","route_result_group"+lineCode);
                                routeGroup.classList.add("route_show_temp");
                                routeGroup.setAttribute("transform","translate("+lineLocation[0]+","+lineLocation[1]+")");
                                routeGroup.appendChild(createPath(namespace,line,resultPath1));
                                routeGroup.appendChild(createPath(namespace,line,resultPath2));
                                metro.parentElement.appendChild(routeGroup);
                                return true;
                            }
                        }else{
                            var pathNext = getCrossPath(next_x, next_y);
                            var intsNext = Snap.path.intersection(resultPath, pathNext);
                            if(!intsNext || intsNext.length<=0) {
                                defaultLine = false;
                                var resultPath1 = Snap.path.getSubpath(cubicSegments, 0, loct1);
                                var resultPath2 = Snap.path.getSubpath(cubicSegments, loct2, linePathLength);
                               
                                var routeGroup = document.createElementNS(namespace,'g');
                                routeGroup.setAttribute("id","route_result_group"+lineCode);
                                routeGroup.classList.add("route_show_temp");
                                routeGroup.setAttribute("transform","translate("+lineLocation[0]+","+lineLocation[1]+")");
                                routeGroup.appendChild(createPath(namespace,line,resultPath1));
                                routeGroup.appendChild(createPath(namespace,line,resultPath2));
                                metro.parentElement.appendChild(routeGroup);
                                return true;
                            }
                        }
    }

                               if(defaultLine){
    var routeGroup = document.createElementNS(namespace,'g');
    routeGroup.setAttribute("id","route_result_group"+lineCode);
    routeGroup.classList.add("route_show_temp");
    routeGroup.setAttribute("transform","translate("+lineLocation[0]+","+lineLocation[1]+")");
    routeGroup.appendChild(createPath(namespace,line,resultPath));
    metro.parentElement.appendChild(routeGroup);
                               return true;
                               }
}



function getNearestPoint(points, targetX, targetY){
    var minDistence = 99999;
    var point;
    for(var j=0; j<points.length; j++){
        var distence = Math.sqrt(Math.pow(points[j].x-targetX,2) + Math.pow(points[j].y-targetY,2));
        if(distence<minDistence){
            minDistence = distence;
            point = points[j];
        }
    }
    return point;
}

function removeRoutes(type){
    var tempData = document.getElementsByClassName("route_show_temp");
    var offset = 0;
    if(tempData!=null) while(tempData.length>offset){
        if(tempData[offset].id=='line_mask' && type==1){
            offset = 1;
        }else{
            tempData[offset].parentNode.removeChild(tempData[offset]);
        }
    }
};



function resetScale(scale){
//    var svg = document.getElementsByTagName("svg");
//    svg[0].setAttribute("svg-scale",scale);
};

//重设画布大小，加载时执行
function resetSVGSize(width, height){
    var svg = document.getElementsByTagName("svg");
    for(var i=0; i<svg.length; i++){
        var svgWidth = svg[i].getAttribute("width").replace("px","");
        var svgHeight = svg[i].getAttribute("height").replace("px","");
        
        var scale1 = width/svgWidth;
        var scale2 = height/svgHeight;
        var scale = scale1>scale2?scale1:scale2;
        svg[i].setAttribute("width",svgWidth*scale+"px");
        svg[i].setAttribute("height",svgHeight*scale+"px");
        
        if(svg[i].getAttribute("svg-width")==null) svg[i].setAttribute("svg-width",svgWidth);
        if(svg[i].getAttribute("svg-height")==null) svg[i].setAttribute("svg-height",svgHeight);
        if(svg[i].getAttribute("frame-width")==null) svg[i].setAttribute("frame-width",width);
        if(svg[i].getAttribute("frame-height")==null) svg[i].setAttribute("frame-height",height);
        //原始缩放
        if(svg[i].getAttribute("init-scale")==null) svg[i].setAttribute("init-scale",scale);
//        if(svg[i].getAttribute("svg-scale")==null) svg[i].setAttribute("svg-scale",scale);
    }
                       console("---image size : "+svgWidth+","+svgHeight+"---"+scale);
//    window.scrollTo({top:height/2, left:width/2, behavior: "smooth"});
//    var timer = setInterval(function () {
//        window.webkit.messageHandlers.scrollToCenter.postMessage({});
//        clearInterval(timer);
//    },500);
                       return {initScale:scale};
};


function parseStringByArray(array,interceptor){
    var str = "";
    for(var i=0; i<array.length; i++){
        str = str + interceptor + array[i];
    }
    return str;
};

function createPath(namespace, oldPath, d){
    var newPath = document.createElementNS(namespace,'path');
    newPath.setAttribute("d", d);
    newPath.setAttribute("stroke",oldPath.getAttribute("stroke"));
    newPath.setAttribute("stroke-width",oldPath.getAttribute("stroke-width"));
    newPath.setAttribute("stroke-linecap",oldPath.getAttribute("stroke-linecap"));
    newPath.setAttribute("stroke-linejoin",oldPath.getAttribute("stroke-linejoin"));
    return newPath;
};


function getTranslate(element){
    return getTranslateFromElement(element, null);
}
                       
                       
function getTranslateFromElement(element, fromElement){
    var location = [0,0];
    if(element.getAttribute("transform")!=null && (fromElement==null || element!=fromElement)){
        var tr = element.transform;
        var trans = element.getAttribute("transform").split(")");
        for(var i=0; i<trans.length; i++){
            if(trans[i].trim().indexOf("translate(")==0){
                var lct = trans[i].trim().replace("translate(","").split(",");
                location[0] = location[0] + parseFloat(lct[0]);
                location[1] = location[1] + parseFloat(lct[1]);
            }
        }
                       
        //location = element.getAttribute("transform").replace("translate(","").replace(")","").split(",");
    }
    if(element.parentElement!=null && (fromElement==null || element!=fromElement)){
        var parentLocation = getTranslateFromElement(element.parentElement, fromElement);
        location[0] = parseInt(location[0]) + parentLocation[0];
        location[1] = parseInt(location[1]) + parentLocation[1];
    }
    return location;
};
                                             
                       
function slowScrollTo(element, x, y, time){
    var timer = null;
    var nowX = window.pageXOffset;
    var nowY = window.pageYOffset;
    //获取步长
    var xStep = (x-nowX)/10;
    var yStep = (y-nowY)/10;
    var timeStep = time/10;
    var count = 0;
    clearInterval(timer);
    timer = setInterval(function () {
                        nowX = nowX + xStep;
                        nowY = nowY + yStep;
                        count++;
                        //屏幕(页面)滚动
                        element.scrollTo({top:nowY, left:nowX, behavior: "smooth"});  //屏幕(页面)滚动到某个位置
                        //清除定时器
                        if(count>=10) clearInterval(timer);
                        },timeStep);
};

