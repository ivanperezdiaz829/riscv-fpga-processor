#pragma cusp_config logOnlyErrors = yes
#pragma cusp_config useVersion = "13.1"

static const char * get_category(void) { 
	return "Video and Image Processing"; 
}

static const char * get_user_guide_url(void) { 
	return "Video and Image Processing Suite User Guide;http://www.altera.com/literature/ug/ug_vip.pdf"; 
}

static const char * get_release_notes_url(void) { 
	return "Current MegaCore IP Library Release Notes and Errata;http://www.altera.com/literature/lit-rn.jsp"; 
}

static const char * get_weblink_url(void) { 
	return "Video and Image Processing Suite Product Page;http://www.altera.com/products/ip/dsp/image_video_processing/m-alt-vipsuite.html";
}

static const char * get_other_url(void) { 
	return "Altera IP MegaStore;http://www.altera.com/products/ip/ipm-index.html";
}

static const char * get_reference_manual_url(void) { 
	return "Literature Page on the Altera Website;http://www.altera.com/literature/lit-index.html";
}

static const char * get_ordering_codes(void) { 
	return "IPS-VIDEO"; 
}

static const char * get_vendor_id(void) { 
	return "0x6AF7"; 
}

static const char * get_devices_supported(void) { 
	return "STRATIX,STRATIXGX,STRATIXII,STRATIXIIGX,STRATIXIIGXLITE,STRATIXIII,STRATIXIV,STRATIXV,CYCLONEII,CYCLONEIII,HARDCOPYII,TARPON,ARRIAII,ARRIAIIGZ,ARRIAV,ARRIAVGZ,HARDCOPYIII,HARDCOPYIV,STINGRAY,CYCLONEIVE,CYCLONEV";
}

static const char * get_version(void){
#ifdef BETA_IP
	return "13.1;13.1-BETA;13.1-BETA Build 162";
#else
	return "13.1;13.1;13.1 Build 162";
#endif
}
