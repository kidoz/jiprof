package com.mentorgen.tools.profile.output;

final class Math {

	public static double nanoToMilli(long time) {
		return ((double) time)/1000000;
	}
	
	public static double toPercent(long num, double denom) {
		return (((double) num)/ denom) * 100;		
	}
}
