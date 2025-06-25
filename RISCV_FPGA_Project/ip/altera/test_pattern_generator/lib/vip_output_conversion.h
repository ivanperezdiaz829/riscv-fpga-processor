sc_int<64> MK_FNAME(ODTC_FNAME,output_type_conversion)(sc_int<64> input)
{
    //the extra bit prevents possible overflow when adding 0.5
    sc_int<64> input_plus_point_five;
    sc_int<64> no_fraction;

    //perform output result shifting
#if ODTC_RSHIFT_DATA>0
	#if ODTC_FIXEDPOINT_TO_INTEGER==FRACTION_BITS_TRUNCATE
	no_fraction = input >> ODTC_RSHIFT_DATA;
	#elif ODTC_FIXEDPOINT_TO_INTEGER==FRACTION_BITS_ROUND_HALF_UP
	input_plus_point_five = input + sc_int<64>(ODTC_POINT_FIVE_BIT);
	no_fraction = input_plus_point_five >> ODTC_RSHIFT_DATA;
	#else //half even rounding, this is not yet optimal
    sc_int<64> xorer = 1 << (ODTC_RSHIFT_DATA);
    sc_int<64> input_added_xord;
    sc_int<64> input_xord_selected;
	input_plus_point_five = input + sc_int<64>(ODTC_POINT_FIVE_BIT);
	input_added_xord = input_plus_point_five ^ xorer;
	input_xord_selected = (input_plus_point_five.range(ODTC_RSHIFT_DATA-1,0)==0 && input_plus_point_five.bit(ODTC_RSHIFT_DATA)==true) ? input_added_xord :input_plus_point_five;		
	no_fraction = input_xord_selected >> ODTC_RSHIFT_DATA;		
	#endif
#else
    //the result must require left shifting or not shifting at all
	no_fraction = input << (-ODTC_RSHIFT_DATA);
#endif

	//convert negatives to absolute positives if required
   	sc_int<64> sign_converted;
#if ODTC_INPUT_DATA_TYPE==DATA_TYPE_SIGNED && ODTC_OUTPUT_DATA_TYPE==DATA_TYPE_UNSIGNED && ODTC_CONVERT_SIGNED_TO_UNSIGNED==CONVERT_TO_UNSIGNED_ABSOLUTE
    sign_converted = no_fraction < sc_int<64>(0) ? sc_int<64>(sc_int<64>(0) - no_fraction) : no_fraction;
#else
    sign_converted = no_fraction;
#endif

    //POST SATURATE TO GUARD BANDS ALWAYS, where guard bands are guardbands of bps (lower)
    sc_int<64> output_sat_max;
    sc_int<64> output_sat_min;
    
    //check upper guard
    output_sat_max = sign_converted > sc_int<64>(ODTC_MAXIMUM_OUTPUT_CONSTRAINT) ?
                     sc_int<64>(ODTC_MAXIMUM_OUTPUT_CONSTRAINT) : sign_converted;
    //check lower guard
	output_sat_min = output_sat_max < sc_int<64>(ODTC_MINIMUM_OUTPUT_CONSTRAINT) ?
                     sc_int<64>(ODTC_MINIMUM_OUTPUT_CONSTRAINT) : output_sat_max;

    return output_sat_min;

}
