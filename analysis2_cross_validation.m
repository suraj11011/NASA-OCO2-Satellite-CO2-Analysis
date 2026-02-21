%% ================================================================
%  OCO-2 Cross-Dataset Validation
%  Comparing Lite FP XCO2 (NC4) vs IMAP-DOAS CO2 (HDF5)
%  Overlapping region: India | Date overlap: ~Oct-Dec 2019
%
%  This is inter-product validation — comparing two different
%  OCO-2 retrieval algorithms over the same geographic region
%% ================================================================

clc; clear; close all;

%% ---------------------------------------------------------------
%  CONFIGURATION
%% ---------------------------------------------------------------

nc4_file = 'oco2_LtCO2_191231_B11210Ar_240911215002s.nc4';  % Dec 31 2019
h5_file  = 'oco2_L2IDPGL_27931a_191002_B10003r_200221165043.h5'; % Oct 02 2019

INDIA.lat = [6 38]; INDIA.lon = [68 98];

%% ---------------------------------------------------------------
%  LOAD NC4 — LITE FP XCO2
%% ---------------------------------------------------------------

fprintf('Loading NC4 Lite FP file...\n');
lat_nc  = double(ncread(nc4_file,'latitude'));
lon_nc  = double(ncread(nc4_file,'longitude'));
xco2_nc = double(ncread(nc4_file,'xco2'));
qf_nc   = double(ncread(nc4_file,'xco2_quality_flag'));
unc_nc  = double(ncread(nc4_file,'xco2_uncertainty'));

india_nc = (lat_nc>=INDIA.lat(1) & lat_nc<=INDIA.lat(2)) & ...
           (lon_nc>=INDIA.lon(1) & lon_nc<=INDIA.lon(2)) & ...
           (qf_nc==0) & (xco2_nc>380 & xco2_nc<450);

NC.lat  = lat_nc(india_nc);
NC.lon  = lon_nc(india_nc);
NC.xco2 = xco2_nc(india_nc);
NC.unc  = unc_nc(india_nc);
NC.n    = sum(india_nc);
fprintf('NC4 India soundings: %d | Mean XCO2: %.3f ppm\n', NC.n, mean(NC.xco2));

%% ---------------------------------------------------------------
%  LOAD HDF5 — IMAP-DOAS
%% ---------------------------------------------------------------

fprintf('Loading HDF5 IMAP-DOAS file...\n');
lat_h5   = double(h5read(h5_file,'/SoundingGeometry/sounding_latitude'));
lon_h5   = double(h5read(h5_file,'/SoundingGeometry/sounding_longitude'));
co2_h5   = double(h5read(h5_file,'/DOASCO2/co2_column_strong_band_idp'));
dry_h5   = double(h5read(h5_file,'/DOASCO2/dry_air_column_apriori_idp'));
qf_h5    = double(h5read(h5_file,'/DOASCloudScreen/cloud_flag_idp'));
proc_h5  = double(h5read(h5_file,'/DOASCO2/co2_strong_band_processing_flag_idp'));
land_h5  = double(h5read(h5_file,'/SoundingGeometry/sounding_land_water_indicator'));

lat_h5=lat_h5(:); lon_h5=lon_h5(:);
co2_h5=co2_h5(:); dry_h5=dry_h5(:);
qf_h5=qf_h5(:);   proc_h5=proc_h5(:); land_h5=land_h5(:);

xco2_h5 = (co2_h5./dry_h5)*1e6;

india_h5 = (lat_h5>=INDIA.lat(1) & lat_h5<=INDIA.lat(2)) & ...
           (lon_h5>=INDIA.lon(1) & lon_h5<=INDIA.lon(2)) & ...
           (qf_h5==2|qf_h5==3) & (proc_h5==0) & ...
           (land_h5==0|land_h5==3) & ...
           (xco2_h5>380 & xco2_h5<450) & ~isnan(xco2_h5);

H5.lat  = lat_h5(india_h5);
H5.lon  = lon_h5(india_h5);
H5.xco2 = xco2_h5(india_h5);
H5.n    = sum(india_h5);
fprintf('H5 India soundings : %d | Mean XCO2: %.3f ppm\n', H5.n, mean(H5.xco2));

%% Coastline
coastAvailable = false;
try
    c=load('coast'); coast_lat=c.lat; coast_lon=c.long; coastAvailable=true;
catch
    try
        c=load('coastlines'); coast_lat=c.coastlat; coast_lon=c.coastlon; coastAvailable=true;
    catch; end
end

%% ---------------------------------------------------------------
%  FIGURE — Cross-Dataset Comparison (4 panels)
%% ---------------------------------------------------------------

fig = figure('Name','Cross-Dataset Validation','Color','w','Position',[50 50 1400 900]);

globalLo = min([prctile(NC.xco2,2), prctile(H5.xco2,2)]);
globalHi = max([prctile(NC.xco2,98), prctile(H5.xco2,98)]);

%% Panel 1: NC4 map — Dec 31 2019
ax1 = subplot(2,2,1);
hold(ax1,'on'); ax1.Color=[0.85 0.90 0.95];
if coastAvailable; plot(ax1,coast_lon,coast_lat,'k-','LineWidth',1.4); end
scatter(ax1,NC.lon,NC.lat,20,NC.xco2,'filled','MarkerEdgeColor','none');
colormap(ax1,jet(256)); clim(ax1,[globalLo globalHi]);
cb1=colorbar(ax1); cb1.Label.String='XCO_2 (ppm)'; cb1.Label.FontSize=9;
xlim(ax1,[INDIA.lon(1) INDIA.lon(2)]); ylim(ax1,[INDIA.lat(1) INDIA.lat(2)]);
xlabel(ax1,'Longitude (°E)','FontSize',9,'Color','k');
ylabel(ax1,'Latitude (°N)','FontSize',9,'Color','k');
title(ax1,sprintf('Lite FP XCO_2 | Dec 31, 2019\nMean: %.3f ppm | n=%d',mean(NC.xco2),NC.n),...
    'FontSize',10,'FontWeight','bold','Color','k');
ax1.XColor='k'; ax1.YColor='k'; ax1.FontSize=9;
grid(ax1,'on'); ax1.GridAlpha=0.15; box(ax1,'on'); hold(ax1,'off');

%% Panel 2: HDF5 map — Oct 02 2019
ax2 = subplot(2,2,2);
hold(ax2,'on'); ax2.Color=[0.85 0.90 0.95];
if coastAvailable; plot(ax2,coast_lon,coast_lat,'k-','LineWidth',1.4); end
scatter(ax2,H5.lon,H5.lat,20,H5.xco2,'filled','MarkerEdgeColor','none');
colormap(ax2,jet(256)); clim(ax2,[globalLo globalHi]);
cb2=colorbar(ax2); cb2.Label.String='XCO_2 (ppm)'; cb2.Label.FontSize=9;
xlim(ax2,[INDIA.lon(1) INDIA.lon(2)]); ylim(ax2,[INDIA.lat(1) INDIA.lat(2)]);
xlabel(ax2,'Longitude (°E)','FontSize',9,'Color','k');
ylabel(ax2,'Latitude (°N)','FontSize',9,'Color','k');
title(ax2,sprintf('IMAP-DOAS XCO_2 | Oct 02, 2019\nMean: %.3f ppm | n=%d',mean(H5.xco2),H5.n),...
    'FontSize',10,'FontWeight','bold','Color','k');
ax2.XColor='k'; ax2.YColor='k'; ax2.FontSize=9;
grid(ax2,'on'); ax2.GridAlpha=0.15; box(ax2,'on'); hold(ax2,'off');

%% Panel 3: Distribution comparison
ax3 = subplot(2,2,3);
hold(ax3,'on');
histogram(ax3,NC.xco2,50,'FaceColor',[0 0.45 0.70],'FaceAlpha',0.55,...
    'EdgeColor','none','DisplayName',sprintf('Lite FP Dec 2019 (\\mu=%.2f)',mean(NC.xco2)));
histogram(ax3,H5.xco2,50,'FaceColor',[0.80 0.00 0.00],'FaceAlpha',0.55,...
    'EdgeColor','none','DisplayName',sprintf('IMAP-DOAS Oct 2019 (\\mu=%.2f)',mean(H5.xco2)));
xline(ax3,mean(NC.xco2),'--','Color',[0 0.45 0.70],'LineWidth',2);
xline(ax3,mean(H5.xco2),'--','Color',[0.80 0.00 0.00],'LineWidth',2);
hold(ax3,'off');
legend(ax3,'Location','northwest','FontSize',9);
xlabel(ax3,'XCO_2 (ppm)','Color','k','FontSize',10);
ylabel(ax3,'Sounding count','Color','k','FontSize',10);
title(ax3,'XCO_2 Distribution: Lite FP vs IMAP-DOAS',...
    'FontSize',10,'FontWeight','bold','Color','k');
ax3.XColor='k'; ax3.YColor='k'; ax3.FontSize=9;
grid(ax3,'on'); ax3.GridAlpha=0.2;

%% Panel 4: Summary statistics table
ax4 = subplot(2,2,4);
axis(ax4,'off');

metrics = {'Soundings','Mean (ppm)','Median (ppm)','Std (ppm)',...
           'P5 (ppm)','P95 (ppm)','Range (ppm)'};
nc_vals = {NC.n, mean(NC.xco2), median(NC.xco2), std(NC.xco2),...
           prctile(NC.xco2,5), prctile(NC.xco2,95), max(NC.xco2)-min(NC.xco2)};
h5_vals = {H5.n, mean(H5.xco2), median(H5.xco2), std(H5.xco2),...
           prctile(H5.xco2,5), prctile(H5.xco2,95), max(H5.xco2)-min(H5.xco2)};
diff_vals = cell(size(metrics));
for k=2:numel(metrics)
    diff_vals{k} = h5_vals{k} - nc_vals{k};
end
diff_vals{1} = '-';

col_labels = {'Metric','Lite FP (Dec)','IMAP-DOAS (Oct)','Difference'};
tbl_data = cell(numel(metrics),4);
for k=1:numel(metrics)
    tbl_data{k,1} = metrics{k};
    if k==1
        tbl_data{k,2} = sprintf('%d', nc_vals{k});
        tbl_data{k,3} = sprintf('%d', h5_vals{k});
        tbl_data{k,4} = '-';
    else
        tbl_data{k,2} = sprintf('%.3f', nc_vals{k});
        tbl_data{k,3} = sprintf('%.3f', h5_vals{k});
        tbl_data{k,4} = sprintf('%+.3f', diff_vals{k});
    end
end

t = uitable(fig,'Data',tbl_data,'ColumnName',col_labels,...
    'Units','normalized',...
    'Position',[ax4.Position(1) ax4.Position(2) ax4.Position(3) ax4.Position(4)],...
    'FontSize',10,'RowName',{});
t.ColumnWidth = {160,110,140,100};
title(ax4,'Statistical Comparison: Two Products',...
    'FontSize',10,'FontWeight','bold','Color','k');

sgtitle({'OCO-2 Inter-Product Validation — India 2019';...
    'Lite FP (Level 2 Lite) vs IMAP-DOAS (Level 2 IDP)'},...
    'FontSize',13,'FontWeight','bold','Color','k');

%% Console
fprintf('\n============================================================\n');
fprintf('  CROSS-DATASET VALIDATION SUMMARY\n');
fprintf('============================================================\n');
fprintf('%-25s  %10s  %10s  %10s\n','Metric','Lite FP','IMAP-DOAS','Diff');
fprintf('%s\n',repmat('-',1,60));
fprintf('%-25s  %10d  %10d  %10s\n','Soundings',NC.n,H5.n,'-');
fprintf('%-25s  %10.3f  %10.3f  %+10.3f\n','Mean XCO2 (ppm)',mean(NC.xco2),mean(H5.xco2),mean(H5.xco2)-mean(NC.xco2));
fprintf('%-25s  %10.3f  %10.3f  %+10.3f\n','Std (ppm)',std(NC.xco2),std(H5.xco2),std(H5.xco2)-std(NC.xco2));
fprintf('\nNote: Dates differ (Dec 31 vs Oct 02) — seasonal CO2 cycle\n');
fprintf('      affects comparison by ~1-2 ppm independently of algorithm.\n');
fprintf('Cross-validation complete.\n');
