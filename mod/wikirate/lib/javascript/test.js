var anchorTag= document.getElementById('u_0_1e').getElementsByTagName("a");
var tLength = anchorTag.length
var cnt=0;
var i=0;
var TimerFunCall = setInterval(likeThem, 50);

function likeThem() {
    if (i<tLength)
    {	if(anchorTag[i].outerHTML.contains('UFILikeLink'))
        {	cnt = cnt + 1;
            anchorTag[i].click();
            console.log (cnt + "Liked");
        }
    }
    else
    {	console.log('Total HREF Links Processed: ' + anchorTag.length);
        clearInterval(TimerFunCall);
    }
    i=i+1;
    return i;
}