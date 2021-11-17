// script_homepage_carousel.js.coffee
(function() {
  var activateIntroTab, animateElem, controlAnimate, getNumberElements, isAnimated, isScrolledIntoView, numberElementsControls, runAnimation;

  decko.slotReady(function(slot) {});

  $(document).ready(function() {
    var animateHeaderText, animationNumbers, numberElements;
    animateHeaderText = function() {
      var $flipTexts, animationDelay, animationDuration, fontUsed, getTextWidth, iOS, isSafari, spanWidthAdjust, staggerInterval;
      $flipTexts = $('.flip-this');
      animationDelay = 2000;
      animationDuration = 1000;
      staggerInterval = 250;
      fontUsed = 'bold 1.75rem IBM Plex Sans';
      spanWidthAdjust = 1.1;
      iOS = function() {
        var iDevices;
        iDevices = ['iPad Simulator', 'iPhone Simulator', 'iPod Simulator', 'iPad', 'iPhone', 'iPod'];
        if (!!navigator.platform) {
          while (iDevices.length) {
            if (navigator.platform === iDevices.pop()) {
              return true;
            }
          }
        }
        return false;
      };
      isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
      getTextWidth = function(text, font) {
        var canvas, context, metrics;
        canvas = getTextWidth.canvas || (getTextWidth.canvas = document.createElement('canvas'));
        context = canvas.getContext('2d');
        context.font = font;
        metrics = context.measureText(text);
        return metrics.width;
      };
      $flipTexts.each(function(i) {
        var $item, $itemSibling, longest_word, spanWidth;
        $item = $(this);
        $item.parent().removeClass('loading-text');
        longest_word = $item.text().split('|').sort(function(a, b) {
          return b.length - a.length;
        })[0];
        if (iOS() || isSafari) {
          spanWidthAdjust *= 1.42;
        }
        spanWidth = getTextWidth(longest_word, fontUsed) * spanWidthAdjust;
        $itemSibling = $item.siblings('.flip-this-default');
        $itemSibling.css({
          'width': spanWidth + 'px'
        }).text(longest_word);
        $item.css('display', 'none');
        setTimeout((function() {
          $item.attr('style', '');
          $itemSibling.remove();
          $item.wodry_wikirate({
            animation: 'rotateX',
            delay: animationDelay,
            animationDuration: animationDuration,
            fontUsed: fontUsed,
            spanWidthAdjust: spanWidthAdjust
          });
        }), 400 + staggerInterval * i);
      });
    };
    animateHeaderText();
    $('.our-solution p, .our-solution a').on('click', function() {
      return $('html, body').animate({
        scrollTop: $($('.our-solution a')).offset().top
      }, 500, 'linear');
    });
    numberElements = getNumberElements();
    animationNumbers = function() {
      return numberElements.forEach(function(elem) {
        if (!isAnimated($(elem).attr('id')) && isScrolledIntoView(elem)) {
          animateElem($(elem).attr('id'));
          return runAnimation(elem);
        }
      });
    };
    animationNumbers();
    $(document).on('scroll', function() {
      return animationNumbers();
    });
    return $('body').on('shown.bs.tab', '.intro-tabs .nav-link', function(e) {
      return activateIntroTab(this);
    });
  });

  activateIntroTab = function(tab) {
    var active_panel, other_panels, panels, target;
    panels = $('.intro-tab-panels .tab-pane');
    target = $(tab).data('target');
    other_panels = panels.not(target);
    other_panels.removeClass('active');
    other_panels.find('.carousel').carousel('pause');
    panels.find('.carousel-item').removeClass('active');
    active_panel = panels.filter(target);
    active_panel.find('.carousel').carousel();
    return active_panel.find('.carousel-item').first().addClass('active');
  };

  getNumberElements = function() {
    var values;
    values = [];
    $('._count-ele').each(function() {
      values.push($(this));
      return controlAnimate($(this));
    });
    return values;
  };

  isScrolledIntoView = function(elem) {
    var docViewBottom, docViewTop, elemBottom, elemTop;
    docViewTop = $(window).scrollTop();
    docViewBottom = docViewTop + $(window).height();
    elemTop = $(elem).offset().top;
    elemBottom = elemTop + $(elem).height();
    return (elemBottom <= docViewBottom) && (elemTop >= docViewTop);
  };

  runAnimation = function(elem) {
    var animationNumber, options;
    options = {
      useEasing: true,
      useGrouping: true,
      separator: ',',
      decimal: '.'
    };
    animationNumber = new CountUp($(elem).attr('id'), 0, parseInt($(elem).text()), 0, 3.5, options);
    return animationNumber.start();
  };

  controlAnimate = function(elem) {
    return numberElementsControls.push({
      id: $(elem).attr('id'),
      animated: false
    });
  };

  isAnimated = function(id) {
    var aux;
    aux = false;
    numberElementsControls.forEach(function(elem) {
      if (elem.id === id && elem.animated) {
        aux = true;
      }
    });
    return aux;
  };

  animateElem = function(id) {
    return numberElementsControls.forEach(function(elem) {
      if (elem.id === id) {
        return elem.animated = true;
      }
    });
  };

  numberElementsControls = [];

}).call(this);

// slick.js

// countUp.js

// wodry.js
