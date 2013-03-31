/**
 * @author leo
 */
public class CalcLatLongDistance {
    /**
     * convert input angle into radian
     * 
     * @param angle    [0, 180]
     * @return the double radian
     */
    private static double radian(double angle) {
        return angle * Math.PI / 180.0;
    }

    /**
     * radius of earth, in meters
     */
    public static final double EARTH_RADIUS = 6378137;

    /**
     * transformation rate for longitude and latitude from real double to an
     * integer (lingtu lo la) real_lo = lingtu_lo / LT_Ratio real_la = lingtu_la
     * / LT_Ratio
     */
    public static final double LT_TRANFOR_RATIO = 1e5;

    public static double getDistance(double lo1, double la1, double lo2, double la2) {
        if (lo1 == 0.0 && la1 == 0.0) {
            return Double.MAX_VALUE;
        }
        if (lo2 == 0.0 && la2 == 0.0) {
            return Double.MAX_VALUE;
        }

        double RATIO = LT_TRANFOR_RATIO;
        if (lo1 > RATIO / 100)
            lo1 = lo1 / RATIO;
        if (la1 > RATIO / 100)
            la1 = la1 / RATIO;
        if (lo2 > RATIO / 100)
            lo2 = lo2 / RATIO;
        if (la2 > RATIO / 100)
            la2 = la2 / RATIO;

        double radLat1 = radian(la1);
        double radLat2 = radian(la2);
        double a = radLat1 - radLat2;
        double b = radian(lo1) - radian(lo2);
        double dist = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a / 2), 2)
                + Math.cos(radLat1) * Math.cos(radLat2)
                * Math.pow(Math.sin(b / 2), 2)));
        dist *= EARTH_RADIUS;
        return dist;
    }

    public static void main(String[] args) {
        System.out.println(getDistance(116.32957, 39.9954, 116.32951, 39.99529));
    }
}
