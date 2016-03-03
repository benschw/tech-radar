'use strict';
/**
 * @fileoverview Master bootstrap file.
 */
goog.provide('demo.app.Draggable');


/**
 * Draggable Directive
 * @param  {*=} $document (not defined in externs)
 * @constructor
 * @ngInject
 */
demo.app.Draggable = function($document) {
	return function(scope, element, $attr) {
		console.log([$document, scope, element, $attr]);
		var startX = 0;
		var startY = 0;
		var x = 0;
		var y = 0;

		element.css({
			position: 'absolute',
			cursor: 'pointer'
		});

		element.on('mousedown', function(event) {
			if (!scope.editable) {
				return;
			}
			// Prevent default dragging of selected content
			event.preventDefault();
			startX = event.pageX - x;
			startY = event.pageY - y;
			$document.on('mousemove', mousemove);
			$document.on('mouseup', mouseup);
		});

		function mousemove(event) {
			y = event.pageY - startY;
			x = event.pageX - startX;

			transform();
		}
		function transform() {
			element.css({
				transform: 'translate('+x+'px,'+y+'px)',
				WebkitTransform: 'translate('+x+'px,'+y+'px)'
			});
			element.css('transform');
		}
		function mouseup() {
			scope.radar.updateLocation($attr.myDraggable, x, y);
			x = 0;
			y = 0;
			transform();
			$document.off('mousemove', mousemove);
			$document.off('mouseup', mouseup);
		}
	};
};
