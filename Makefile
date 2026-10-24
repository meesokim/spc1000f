all: top.bit top.mcs

top.bit top.mcs:
	./build.sh

clean:
	rm -rf xst _ngo _xmsgs top*.ncd top*.ngc top*.ngd top*.pcf top*.bgn top*.bit top*.mcs top*.drc top*.pad top*.par top*.ptwx top*.unroutes top*.xpi top*.twr top*.twx top*.syr top_map.* top_summary.xml top_usage.xml par_usage_statistics.html webtalk.log
