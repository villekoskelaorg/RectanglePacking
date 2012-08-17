/**
 * Rectangle Packer v1.0.2
 *
 * Copyright 2012 Ville Koskela. All rights reserved.
 *
 * Blog: http://villekoskela.org
 * Twitter: @villekoskelaorg
 *
 * You may redistribute, use and/or modify this source code freely
 * but this copyright statement must not be removed from the source files.
 *
 * The package structure of the source code must remain unchanged.
 * Mentioning the author in the binary distributions is highly appreciated.
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *
 *
 */
package org.villekoskela.utils
{
    import flash.geom.Rectangle;

    /**
     * Class used to pack rectangles within containers rectangle with close to optimal solution.
     * To keep the implementation simple no instance pooling or any other advanced techniques
     * are used.
     */
    public class RectanglePacker
    {
        public static const VERSION:String = "1.0.2";
        private var mWidth:int = 0;
        private var mHeight:int = 0;

        private var mInsertedRectangles:Vector.<Rectangle> = new Vector.<Rectangle>();
        private var mFreeAreas:Vector.<Rectangle> = new Vector.<Rectangle>();

        private var mOutsideRectangle:Rectangle;
        private var mRectangleStack:Vector.<Rectangle> = new Vector.<Rectangle>();

        public function get rectangleCount():int { return mInsertedRectangles.length; }

        /**
         * Constructs new rectangle packer
         * @param width the width of the main rectangle
         * @param height the height of the main rectangle
         */
        public function RectanglePacker(width:int, height:int)
        {
            mOutsideRectangle = new Rectangle(width + 1, height + 1, 0, 0);
            reset(width, height);
        }

        /**
         * Resets the rectangle packer with given dimensions
         * @param width
         * @param height
         */
        public function reset(width:int, height:int):void
        {
            while (mInsertedRectangles.length)
            {
                freeRectangle(mInsertedRectangles.pop());
            }

            while (mFreeAreas.length)
            {
                freeRectangle(mFreeAreas.pop());
            }

            mWidth = width;
            mHeight = height;
            mFreeAreas.push(allocateRectangle(0, 0, mWidth, mHeight));
        }

        /**
         * Gets the position of the rectangle in given index in the main rectangle
         * @param index the index of the rectangle
         * @param rectangle an instance where to set the rectangle's values
         * @return
         */
        public function getRectangle(index:int, rectangle:Rectangle):Rectangle
        {
            if (rectangle)
            {
                rectangle.copyFrom(mInsertedRectangles[index]);
                return rectangle;
            }

            return mInsertedRectangles[index].clone();
        }

        /**
         * Tries to insert new rectangle into the packer
         * @param rectangle
         * @return true if inserted successfully
         */
        public function insertRectangle(rectangle:Rectangle):Boolean
        {
            var index:int = getFreeAreaIndex(rectangle);
            if (index < 0)
            {
                return false;
            }

            var freeArea:Rectangle = mFreeAreas[index];
            var target:Rectangle = allocateRectangle(freeArea.left, freeArea.top, rectangle.width, rectangle.height);

            // Get the new free areas, these are parts of the old ones intersected by the target
            var newFreeAreas:Vector.<Rectangle> = generateNewSubAreas(target, mFreeAreas);
            filterSubAreas(newFreeAreas, mFreeAreas);

            for (var i:int = newFreeAreas.length - 1; i >= 0; i--)
            {
                mFreeAreas.push(newFreeAreas[i]);
            }

            mInsertedRectangles.push(target);
            return true;
        }

        /**
         * Returns the bounding rectangle for the given list of rectangles
         * @param areas the list of rectangles
         * @return the bounding rectangle or null if empty list given
         */
        private function getBoundingRectangle(areas:Vector.<Rectangle>, result:Rectangle = null):Rectangle
        {
            if (areas.length == 0)
            {
                return null;
            }

            if (result == null)
            {
                result = allocateRectangle(0, 0, 0, 0);
            }

            result.copyFrom(areas[0]);
            for (var i:int = areas.length - 1; i >= 0; i--)
            {
                var area:Rectangle = areas[i];
                if (area.x < result.x)
                {
                    result.x = area.x;
                }
                if (area.y < result.y)
                {
                    result.y = area.y;
                }
                if (area.x + area.width > result.x + result.width)
                {
                    result.width = area.x + area.width - area.x;
                }
                if (area.y + area.height > result.y + result.height)
                {
                    result.height = area.y + area.height - area.y;
                }
            }

            return result;
        }

        /**
         * Removes rectangles from the filteredAreas that are sub rectangles of any rectangle in areas.
         * @param filteredAreas rectangles to be filtered
         * @param areas rectangles against which the filtering is performed, must not be equal to filteredAreas
         */
        private function filterSubAreas(filteredAreas:Vector.<Rectangle>, areas:Vector.<Rectangle>):void
        {
            if (filteredAreas.length == 0)
            {
                return;
            }

            var bounding:Rectangle = getBoundingRectangle(filteredAreas);

            for (var i:int = areas.length - 1; i >= 0; i--)
            {
                // First check that the bounding box of the filtered rectangles even intersects this area
                var area:Rectangle = areas[i];
                if (!(bounding.x >= area.x + area.width || bounding.x + bounding.width <= area.x ||
                      bounding.y >= area.y + area.height || bounding.y + bounding.height <= area.y))
                {
                    for (var j:int = filteredAreas.length - 1; j >= 0; j--)
                    {
                        var filtered:Rectangle = filteredAreas[j];
                        if (area.x <= filtered.x && area.y <= filtered.y &&
                            area.x + area.width >= filtered.x + filtered.width &&
                            area.y + area.height >= filtered.y + filtered.height)
                        {
                            freeRectangle(filtered);
                            filteredAreas.splice(j, 1);
                            if (filteredAreas.length == 0)
                            {
                                return;
                            }
                            bounding = getBoundingRectangle(filteredAreas, bounding);
                        }
                    }
                }
            }
        }

        /**
         * Removes rectangles from the filteredAreas that are sub rectangles of any rectangle in areas.
         * @param areas rectangles from which the filtering is performed
         */
        private function filterSelfSubAreas(areas:Vector.<Rectangle>):void
        {
            for (var i:int = areas.length - 1; i >= 0; i--)
            {
                var filtered:Rectangle = areas[i];
                for (var j:int = areas.length - 1; j >= 0; j--)
                {
                    var area:Rectangle = areas[j];
                    if (area.x <= filtered.x && area.y <= filtered.y &&
                        area.x + area.width >= filtered.x + filtered.width &&
                        area.y + area.height >= filtered.y + filtered.height &&
                        (area.width > filtered.width || area.height > filtered.height))
                    {
                        freeRectangle(filtered);
                        areas.splice(i, 1);
                        break;
                    }
                }
            }
        }

        /**
         * Checks what areas the given rectangle intersects, removes those areas and
         * returns the list of new areas those areas are divived into
         * @param target the new rectangle that is dividing the areas
         * @param areas the areas to be divided
         * @return list of new areas
         */
        private function generateNewSubAreas(target:Rectangle, areas:Vector.<Rectangle>):Vector.<Rectangle>
        {
            var results:Vector.<Rectangle> = new Vector.<Rectangle>();
            for (var i:int = areas.length - 1; i >= 0; i--)
            {
                var area:Rectangle = areas[i];
                if (!(target.x >= area.x + area.width || target.x + target.width <= area.x ||
                      target.y >= area.y + area.height || target.y + target.height <= area.y))
                {
                    generateDividedAreas(target, area, results);
                    freeRectangle(area);
                    areas.splice(i, 1);
                }
            }

            filterSelfSubAreas(results);
            return results;
        }

        /**
         * Divides the area into new sub areas around the divider.
         * @param divider rectangle that intersects the area
         * @param area rectangle to be divided into sub areas around the divider
         * @param results vector for the new sub areas around the divider
         */
        private function generateDividedAreas(divider:Rectangle, area:Rectangle, results:Vector.<Rectangle>):void
        {
            if (divider.right < area.right)
            {
                results.push(allocateRectangle(divider.right, area.y, area.right - divider.right, area.height));
            }

            if (divider.x > area.x)
            {
                results.push(allocateRectangle(area.x, area.y, divider.x - area.x, area.height));
            }

            if (divider.bottom < area.bottom)
            {
                results.push(allocateRectangle(area.x, divider.bottom, area.width, area.bottom - divider.bottom));
            }

            if (divider.y > area.y)
            {
                results.push(allocateRectangle(area.x, area.y, area.width, divider.y - area.y));
            }
        }

        /**
         * Gets the index of the best free area for the given rectangle
         * @param rectangle
         * @return index of the best free area or -1 if no suitable free area available
         */
        private function getFreeAreaIndex(rectangle:Rectangle):int
        {
            var best:Rectangle = mOutsideRectangle;
            var index:int = -1;

            for (var i:int = mFreeAreas.length - 1; i >= 0; i--)
            {
                var free:Rectangle = mFreeAreas[i];
                if (rectangle.width <= free.width && rectangle.height <= free.height)
                {
                    if (free.x < best.x || (free.x == best.x && free.y < best.y))
                    {
                        index = i;
                        best = free;
                    }
                }
            }

            return index;
        }

        /**
         * Allocates new rectangle. If one available in stack uses that, otherwise new.
         * @param x
         * @param y
         * @param width
         * @param height
         * @return
         */
        private function allocateRectangle(x:Number, y:Number, width:Number, height:Number):Rectangle
        {
            if (mRectangleStack.length > 0)
            {
                var rectangle:Rectangle = mRectangleStack.pop();
                rectangle.x = x;
                rectangle.y = y;
                rectangle.width = width;
                rectangle.height = height;
                return rectangle;
            }

            return new Rectangle(x, y, width, height);
        }

        /**
         * Pushes the freed rectangle to rectangle stack. Make sure not to push same rectangle twice!
         * @param rectangle
         */
        private function freeRectangle(rectangle:Rectangle):void
        {
            mRectangleStack.push(rectangle);
        }
    }
}
