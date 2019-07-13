pragma solidity >= 0.5.0 <0.6.0;

/* A mathematical library allowing safely operations on BN (big numbers) - in solidity uint256.
 */

library SafeMath {
    /* Multiplies two BN
     * @param {uint256} a - first factor
     * @param {uint256} b - second factor
     * @return {uint256} c - The result of the multiplication.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);

        return c;
    }

    /* Divides two BN
     * @param {uint256} a - dividend
     * @param {uint256} b - divisor
     * @return {uint256} c - The result of the division.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Cannot dividing by zero");
        uint256 c = a / b;

        return c;
    }

    /* Adding two BN
     * @param {uint256} a - first component
     * @param {uint256} b - second component
     * @return {uint256} c - The result of the addition operation.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }

    /* Substracts two BN
     * @param {uint256} a - minuend
     * @param {uint256} b - subtrahend
     * @return {uint256} c - The result of the subtraction.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* Modulo operation
     * @param {uint256} a - dividend
     * @param {uint256} b - divisor
     * @return {uint256} c - Finds the remainder after division of one BN by another.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Second parameter cannot be a zero");
        return a % b;
    }
}