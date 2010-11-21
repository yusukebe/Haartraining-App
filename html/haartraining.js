var canvas;
var firstPoint;
var results = new Array();
var imgSrc;

$().ready(function(){
    imageSrc = window.location.search;
    imageSrc = imageSrc.replace('?image=','/images/');
    var img = $('<img/>').attr('src',imageSrc);
    img.bind('load',function(){
        init();
    });
    $(window).keydown(function(e){
        if(e.keyCode == 32){
            var param = '';
            jQuery.each(results,function(){
                param += Math.floor(this.x) + ',' + Math.floor(this.y) + ','
                    + Math.floor(this.width) + ',' + Math.floor(this.height) + ',';
            });
            var path = imageSrc.replace('/images/','');
            jQuery.post('/post',{
                param: param, image : path
            },function(){
                window.location.replace('/');
            });
        }
    });
});

function init(){
    var div = $('<canvas/>').attr('id','canvas').attr('width',900).attr('height',600);
    $('#canvas-container').append(div);
    canvas  = document.getElementById('canvas');
    if ( ! canvas || ! canvas.getContext ) { return false; }
    var ctx = canvas.getContext('2d');
    var image = new Image();
    image.src = imageSrc;
    ctx.drawImage(image, 0, 0);

    $('#canvas').click(function(e){
        var clickX = e.pageX - $('#canvas').position().left;
        var clickY = e.pageY - $('#canvas').position().top;
        if(firstPoint){
            var width = Math.abs(firstPoint['x'] - clickX);
            var height = Math.abs(firstPoint['y'] - clickY);
            if( firstPoint['x'] > clickX){
                x = clickX;
            }else{
                x = firstPoint['x'];
            }
            if( firstPoint['y'] > clickY){
                y = clickY;
            }else{
                y = firstPoint['y'];
            }
            ctx.strokeStyle = 'rgb(255, 0, 0)';
            ctx.strokeRect(x, y, width , height)
            firstPoint = null;
            results.push({x:x,y:y,width:width,height:height});
        }else{
            firstPoint = { x : clickX, y : clickY };
        }
    });
}
