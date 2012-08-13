/**
 * Scaling Box
 * Copyright 2012 Ville Koskela. All rights reserved.
 *
 * Blog: http://villekoskela.org
 * Twitter: @villekoskelaorg
 *
 * You may redistribute, use and/or modify this class freely
 * but this copyright statement must not be removed.
 *
 * The package structure must remain unchanged.
 *
 */
package org.villekoskela.tools
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * Utility class to provide scalable box functionality.
     */
    public class ScalingBox extends Sprite
    {
        private var mX:Number = 0.0;
        private var mY:Number = 0.0;
        private var mWidth:Number = 0.0;
        private var mHeight:Number = 0.0;
        private var mMaxWidth:Number = 0.0;
        private var mMaxHeight:Number = 0.0;

        private var mNewWidth:Number = 0.0;
        private var mNewHeight:Number = 0.0;

        private var mDragBox:Sprite = new Sprite();
        private var mDragging:Boolean = false;

        public function get boxWidth():Number { return mWidth; }
        public function get boxHeight():Number { return mHeight; }
        public function get newBoxWidth():Number { return mNewWidth; }
        public function get newBoxHeight():Number { return mNewHeight; }

        public function ScalingBox(x:Number, y:Number, width:Number, height:Number)
        {
            mX = x;
            mY = y;

            mMaxWidth = width;
            mMaxHeight = height;

            this.x = x;
            this.y = y;

            mDragBox.graphics.beginFill(0xFF8050);
            mDragBox.graphics.drawCircle(0, 0, 10);
            mDragBox.graphics.endFill();

            addChild(mDragBox);

            mDragBox.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            updateBox(width, height);
        }

        public function updateBox(width:Number, height:Number):void
        {
            mWidth = width;
            mHeight = height;
            mNewWidth = width;
            mNewHeight = height;

            graphics.clear();
            graphics.lineStyle(1.0, 0x000000);
            graphics.drawRect(0, 0, mWidth, mHeight);

            mDragBox.x = mWidth;
            mDragBox.y = mHeight;
        }

        private function onAddedToStage(event:Event):void
        {
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }

        private function onMouseUp(event:MouseEvent):void
        {
            mDragging = false;
        }

        private function onMouseMove(event:MouseEvent):void
        {
            if (mDragging)
            {
                mNewWidth = event.stageX - mX;
                mNewHeight = event.stageY - mY;

                if (mNewWidth > mMaxWidth)
                {
                    mNewWidth = mMaxWidth;
                }

                if (mNewHeight > mMaxHeight)
                {
                    mNewHeight = mMaxHeight;
                }
            }
        }

        private function onStartDrag(event:MouseEvent):void
        {
            mDragging = true;
        }
    }
}
