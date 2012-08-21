/**
 * Created with IntelliJ IDEA.
 * User: ville
 * Date: 21.8.2012
 * Time: 8:17
 */
package org.villekoskela.utils
{
    public class IntegerRectangle
    {
        public var x:int;
        public var y:int;
        public var width:int;
        public var height:int;
        public var right:int;
        public var bottom:int;

        public function IntegerRectangle(x:int = 0, y:int = 0, width:int = 0, height:int = 0)
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            this.right = x + width;
            this.bottom = y + height;
        }
    }
}
