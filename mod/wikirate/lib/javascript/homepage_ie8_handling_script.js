//EnhanceJS isIE test idea

//detect IE and version number through injected conditional comments (no UA detect, no need for cond. compilation / jscript check)

//version arg is for IE version (optional)
//comparison arg supports 'lte', 'gte', etc (optional)

function isIE(version, comparison) {
    var cc = 'IE',
        b = document.createElement('B'),
        docElem = document.documentElement,
        isIE;

    if (version) {
        cc += ' ' + version;
        if (comparison) {
            cc = comparison + ' ' + cc;
        }
    }

    b.innerHTML = '<!--[if ' + cc + ']><b id="iecctest"></b><![endif]-->';
    docElem.appendChild(b);
    isIE = !!document.getElementById('iecctest');
    docElem.removeChild(b);
    return isIE;
}

wagn.slotReady(function (slot) {
    if (isIE("8"))
        $('.STRUCTURE-company_overview .TYPE-image img,\
      .STRUCTURE-topic_overview .TYPE-image img,\
      .overview-item  .company-image img,\
      .overview-item  .topic-image img').css("position", "inherit");
});
