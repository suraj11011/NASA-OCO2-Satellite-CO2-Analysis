%% ================================================================
%  OCO-2 L2 Lite FP V11.2 — Global XCO2 Trend Analysis
%  Analysis 1 of 3 | Part of OCO-2 Carbon & Vegetation Project
%
%  Dates: Dec 31 2019 | Dec 31 2021 | Dec 31 2023 | Oct 31 2025
%
%  Figures produced:
%   Fig 1 — Global XCO2 spatial maps (4 panels) + coastlines
%   Fig 2 — Difference maps vs 2019 baseline + coastlines
%   Fig 3 — Statistical summary (black labels on white)
%   Fig 4 — Global XCO2 distribution histograms (title visible)
%% ================================================================

clc; clear; close all;

%% ---------------------------------------------------------------
%  SECTION 1 — CONFIGURATION
%% ---------------------------------------------------------------

files = {
    'oco2_LtCO2_191231_B11210Ar_240911215002s.nc4';
    'oco2_LtCO2_211231_B11210Ar_240917000151s.nc4';
    'oco2_LtCO2_231231_B11210Ar_240919184624s.nc4';
    'oco2_LtCO2_251031_B11211Ar_251208231304s.nc4';
};

yearLabels  = {'Dec 31, 2019','Dec 31, 2021','Dec 31, 2023','Oct 31, 2025'};
shortLabels = {'2019','2021','2023','2025'};
years       = [2019, 2021, 2023, 2025];

% Regions of interest
regions(1).name='Global';      regions(1).lat=[-90 90];  regions(1).lon=[-180 180];
regions(2).name='SW USA';      regions(2).lat=[30 42];   regions(2).lon=[-115 -100];
regions(3).name='East Asia';   regions(3).lat=[20 50];   regions(3).lon=[100 145];
regions(4).name='Europe';      regions(4).lat=[35 65];   regions(4).lon=[-10 40];
regions(5).name='South Asia';  regions(5).lat=[5 35];    regions(5).lon=[65 100];
nRegions = numel(regions);

GRID_RES = 2.0;  % degrees

% Colorblind-safe year colors
yearColors = [
    0.00 0.45 0.70;   % blue   2019
    0.90 0.62 0.00;   % orange 2021
    0.00 0.62 0.45;   % green  2023
    0.80 0.00 0.00;   % red    2025
];

nFiles = numel(files);

%% ---------------------------------------------------------------
%  SECTION 2 — LOAD COASTLINE DATA
%% ---------------------------------------------------------------

coastAvailable = false;
try
    c = load('coast');
    coast_lat = c.lat; coast_lon = c.long;
    coastAvailable = true;
    fprintf('Coastline loaded (coast.mat)\n');
catch
    try
        c = load('coastlines');
        coast_lat = c.coastlat; coast_lon = c.coastlon;
        coastAvailable = true;
        fprintf('Coastline loaded (coastlines.mat)\n');
    catch
        fprintf('WARNING: No coastline data found. Outlines will be skipped.\n');
    end
end

%% ---------------------------------------------------------------
%  SECTION 3 — LOAD & FILTER ALL NC4 FILES
%% ---------------------------------------------------------------

S = struct();
fprintf('\nLoading OCO-2 Lite FP files...\n\n');

for i = 1:nFiles
    fname = files{i};
    fprintf('=== %s ===\n', yearLabels{i});

    lat    = double(ncread(fname,'latitude'));
    lon    = double(ncread(fname,'longitude'));
    xco2   = double(ncread(fname,'xco2'));
    qflag  = double(ncread(fname,'xco2_quality_flag'));
    uncert = double(ncread(fname,'xco2_uncertainty'));

    fprintf('  Total soundings : %d\n', numel(lat));

    goodMask = (qflag==0) & (xco2>380) & (xco2<450);
    fprintf('  Good soundings  : %d (%.1f%%)\n', sum(goodMask), 100*mean(goodMask));

    S(i).lat    = lat(goodMask);
    S(i).lon    = lon(goodMask);
    S(i).xco2   = xco2(goodMask);
    S(i).uncert = uncert(goodMask);
    S(i).label  = yearLabels{i};
    S(i).year   = years(i);
    S(i).color  = yearColors(i,:);
    S(i).n      = sum(goodMask);
    S(i).empty  = (sum(goodMask)==0);
    S(i).mean   = mean(S(i).xco2);
    S(i).median = median(S(i).xco2);
    S(i).std    = std(S(i).xco2);
    S(i).p5     = prctile(S(i).xco2,5);
    S(i).p95    = prctile(S(i).xco2,95);

    fprintf('  XCO2 Mean   : %.3f ppm\n', S(i).mean);
    fprintf('  XCO2 Std    : %.3f ppm\n\n', S(i).std);

    for r = 1:nRegions
        inReg = S(i).lat>=regions(r).lat(1) & S(i).lat<=regions(r).lat(2) & ...
                S(i).lon>=regions(r).lon(1) & S(i).lon<=regions(r).lon(2);
        if sum(inReg)>0
            S(i).reg_mean(r) = mean(S(i).xco2(inReg));
            S(i).reg_n(r)    = sum(inReg);
        else
            S(i).reg_mean(r) = NaN;
            S(i).reg_n(r)    = 0;
        end
    end
end

%% ---------------------------------------------------------------
%  SECTION 4 — BUILD GLOBAL GRIDS
%% ---------------------------------------------------------------

lonGrid = -180:GRID_RES:180;
latGrid =  -90:GRID_RES:90;
[LON_G, LAT_G] = meshgrid(lonGrid, latGrid);

for i = 1:nFiles
    if S(i).empty; S(i).grid=NaN(size(LON_G)); continue; end

    latIdx = round((S(i).lat-(-90))  / GRID_RES)+1;
    lonIdx = round((S(i).lon-(-180)) / GRID_RES)+1;
    latIdx = max(1,min(latIdx,numel(latGrid)));
    lonIdx = max(1,min(lonIdx,numel(lonGrid)));

    linIdx  = sub2ind(size(LON_G), latIdx, lonIdx);
    gridSum = accumarray(linIdx, S(i).xco2,  [numel(LON_G),1], @mean, NaN);
    gridN   = accumarray(linIdx, ones(S(i).n,1), [numel(LON_G),1], @sum, 0);

    grid2D = reshape(gridSum, size(LON_G));
    gridCnt= reshape(gridN,   size(LON_G));
    grid2D(gridCnt==0) = NaN;

    S(i).grid      = grid2D;
    S(i).gridCount = gridCnt;
    fprintf('Grid %s: %.1f%% cells filled\n', S(i).label, ...
        100*mean(~isnan(grid2D(:))));
end

allMeans = [S.mean];
globalLo = min(allMeans)-3;
globalHi = max(allMeans)+3;

%% ---------------------------------------------------------------
%  FIGURE 1 — GLOBAL XCO2 MAPS WITH COASTLINES
%% ---------------------------------------------------------------

fig1 = figure('Name','OCO-2 Global XCO2 Maps','Color','k',...
              'Position',[20 20 1600 700]);

cmap_co2 = jet(256);

for i = 1:nFiles
    ax = subplot(2,2,i);

    if S(i).empty
        text(0.5,0.5,'No data','Units','normalized','Color','w',...
            'HorizontalAlignment','center','FontSize',14);
        set(ax,'Color','k'); continue;
    end

    imagesc(ax, lonGrid, latGrid, S(i).grid);
    axis(ax,'xy');
    colormap(ax, cmap_co2);
    clim(ax,[globalLo globalHi]);
    set(ax,'Color',[0.05 0.05 0.10]);

    cb = colorbar(ax,'Color','w');
    cb.Label.String  = 'XCO_2 (ppm)';
    cb.Label.Color   = 'w';
    cb.Label.FontSize = 9;

    hold(ax,'on');

    % Coastline overlay
    if coastAvailable
        plot(ax, coast_lon, coast_lat, 'w-', 'LineWidth', 0.7);
    end

    % SW USA highlight box
    rectangle(ax,'Position',[-115,30,15,12],...
        'EdgeColor','w','LineStyle','--','LineWidth',1.2);
    text(ax,-114,43,'SW USA','Color','w','FontSize',7.5,'FontWeight','bold');

    hold(ax,'off');

    xlabel(ax,'Longitude (°)','Color','w','FontSize',9);
    ylabel(ax,'Latitude (°)','Color','w','FontSize',9);
    title(ax,sprintf('%s  |  Mean: %.3f ppm  (n=%d)', ...
        S(i).label, S(i).mean, S(i).n),...
        'Color','w','FontSize',10,'FontWeight','bold');
    ax.XColor='w'; ax.YColor='w';
    xlim(ax,[-180 180]); ylim(ax,[-90 90]);
end

sgtitle('OCO-2 XCO_2 — Global Daily Snapshots | 2019 to 2025',...
    'Color','w','FontSize',14,'FontWeight','bold');

%% ---------------------------------------------------------------
%  FIGURE 2 — DIFFERENCE MAPS WITH COASTLINES
%% ---------------------------------------------------------------

fig2 = figure('Name','XCO2 Change vs 2019','Color','k',...
              'Position',[20 400 1600 380]);

nC=256; half=nC/2;
cmap_diff = [linspace(0,1,half)', linspace(0,1,half)', ones(half,1);
             ones(half,1), linspace(1,0,half)', linspace(1,0,half)'];

for i = 2:nFiles
    ax = subplot(1,3,i-1);

    diffGrid = S(i).grid - S(1).grid;
    imagesc(ax, lonGrid, latGrid, diffGrid);
    axis(ax,'xy');
    colormap(ax, cmap_diff);

    dVals  = diffGrid(~isnan(diffGrid(:)));
    absMax = max([abs(prctile(dVals,2)), abs(prctile(dVals,98)), 1]);
    clim(ax,[-absMax absMax]);

    cb = colorbar(ax,'Color','w');
    cb.Label.String  = '\DeltaXCO_2 (ppm)';
    cb.Label.Color   = 'w';
    cb.Label.FontSize = 9;

    hold(ax,'on');

    % Coastline overlay
    if coastAvailable
        plot(ax, coast_lon, coast_lat, 'w-', 'LineWidth', 0.7);
    end

    rectangle(ax,'Position',[-115,30,15,12],...
        'EdgeColor','w','LineStyle','--','LineWidth',1.2);

    hold(ax,'off');

    netChange = mean(dVals,'omitnan');
    xlabel(ax,'Longitude (°)','Color','w','FontSize',9);
    ylabel(ax,'Latitude (°)','Color','w','FontSize',9);
    title(ax,sprintf('%s vs 2019  |  Net: %+.3f ppm',S(i).label,netChange),...
        'Color','w','FontSize',10,'FontWeight','bold');
    ax.XColor='w'; ax.YColor='w';
    ax.Color=[0.08 0.08 0.12];
    xlim(ax,[-180 180]); ylim(ax,[-90 90]);
end

sgtitle('\DeltaXCO_2 Change vs Dec 31, 2019 Baseline',...
    'Color','w','FontSize',13,'FontWeight','bold');

%% ---------------------------------------------------------------
%  FIGURE 3 — STATISTICAL SUMMARY (black labels)
%% ---------------------------------------------------------------

meanVals = arrayfun(@(x) S(x).mean, 1:nFiles);
stdVals  = arrayfun(@(x) S(x).std,  1:nFiles);
p5Vals   = arrayfun(@(x) S(x).p5,   1:nFiles);
p95Vals  = arrayfun(@(x) S(x).p95,  1:nFiles);

fig3 = figure('Name','XCO2 Statistics','Color','w','Position',[50 50 1100 750]);

%% Panel 1: Mean bar chart
ax1 = subplot(2,2,1);
b = bar(ax1, meanVals,'FaceColor','flat');
for i=1:nFiles; b.CData(i,:)=yearColors(i,:); end
hold(ax1,'on');
errorbar(ax1,1:nFiles,meanVals,stdVals,'k.','LineWidth',1.5,'CapSize',8);
for i=2:nFiles
    delta = meanVals(i)-meanVals(1);
    text(ax1,i,meanVals(i)+stdVals(i)+0.15,sprintf('%+.3f ppm',delta),...
        'HorizontalAlignment','center','FontSize',8,'FontWeight','bold',...
        'Color',yearColors(i,:));
end
hold(ax1,'off');
set(ax1,'XTickLabel',shortLabels,'FontSize',10,'XColor','k','YColor','k');
ylabel(ax1,'Global Mean XCO_2 (ppm)','Color','k');
title(ax1,'Global Mean XCO_2 ± Std Dev','Color','k','FontWeight','bold');
ylim(ax1,[min(meanVals)-1.5, max(meanVals)+1.5]);
grid(ax1,'on'); ax1.GridAlpha=0.3;

%% Panel 2: Trend line
ax2 = subplot(2,2,2);
plot(ax2,years,meanVals,'ko-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','k');
hold(ax2,'on');
for i=1:nFiles
    plot(ax2,years(i),meanVals(i),'o','MarkerSize',11,...
        'MarkerFaceColor',yearColors(i,:),'MarkerEdgeColor','k','LineWidth',1.2);
end
p = polyfit(years,meanVals,1);
xFit = linspace(years(1)-0.5,years(end)+0.5,100);
plot(ax2,xFit,polyval(p,xFit),'r--','LineWidth',1.8);
text(ax2,years(1),polyval(p,years(1))-0.4,...
    sprintf('Trend: %+.3f ppm/yr',p(1)),...
    'Color','red','FontSize',9,'FontWeight','bold');
hold(ax2,'off');
set(ax2,'XTick',years,'FontSize',10,'XColor','k','YColor','k');
xlabel(ax2,'Year','Color','k');
ylabel(ax2,'Global Mean XCO_2 (ppm)','Color','k');
title(ax2,'Global XCO_2 Trend 2019–2025','Color','k','FontWeight','bold');
grid(ax2,'on'); ax2.GridAlpha=0.3;

%% Panel 3: Regional heatmap
ax3 = subplot(2,2,3);
regMat = zeros(nRegions,nFiles);
for i=1:nFiles; regMat(:,i)=S(i).reg_mean; end
imagesc(ax3,regMat);
colormap(ax3,parula(128));
colorbar(ax3);
set(ax3,'XTick',1:nFiles,'XTickLabel',shortLabels,...
        'YTick',1:nRegions,'YTickLabel',{regions.name},...
        'FontSize',9,'XColor','k','YColor','k');
title(ax3,'Regional Mean XCO_2 (ppm)','Color','k','FontWeight','bold');
xlabel(ax3,'Year','Color','k');
for r=1:nRegions
    for i=1:nFiles
        if ~isnan(regMat(r,i))
            text(ax3,i,r,sprintf('%.1f',regMat(r,i)),...
                'HorizontalAlignment','center','FontSize',8,...
                'Color','w','FontWeight','bold');
        end
    end
end

%% Panel 4: P5-P95 range
ax4 = subplot(2,2,4);
hold(ax4,'on');
for i=1:nFiles
    fill(ax4,[i-0.3,i+0.3,i+0.3,i-0.3],...
         [p5Vals(i),p5Vals(i),p95Vals(i),p95Vals(i)],...
         yearColors(i,:),'FaceAlpha',0.5,'EdgeColor',yearColors(i,:),'LineWidth',1.5);
    plot(ax4,[i-0.35,i+0.35],[meanVals(i),meanVals(i)],...
        '-','Color',yearColors(i,:),'LineWidth',3);
    text(ax4,i,p95Vals(i)+0.1,sprintf('%.2f',p95Vals(i)),...
        'HorizontalAlignment','center','FontSize',7,'Color',yearColors(i,:));
    text(ax4,i,p5Vals(i)-0.2,sprintf('%.2f',p5Vals(i)),...
        'HorizontalAlignment','center','FontSize',7,'Color',yearColors(i,:));
end
hold(ax4,'off');
set(ax4,'XTick',1:nFiles,'XTickLabel',shortLabels,...
    'FontSize',10,'XColor','k','YColor','k');
ylabel(ax4,'XCO_2 (ppm)','Color','k');
title(ax4,'P5–P95 Range + Mean per Year','Color','k','FontWeight','bold');
grid(ax4,'on'); ax4.GridAlpha=0.3;

sgtitle('OCO-2 Global XCO_2 — Statistical Summary 2019–2025',...
    'FontSize',13,'FontWeight','bold','Color','k');

%% ---------------------------------------------------------------
%  FIGURE 4 — DISTRIBUTION HISTOGRAMS (title fully visible)
%% ---------------------------------------------------------------

fig4 = figure('Name','XCO2 Distribution','Color','w','Position',[100 100 800 560]);
ax_hist = axes(fig4,'Position',[0.10 0.10 0.82 0.75]);
hold(ax_hist,'on');

for i=1:nFiles
    histogram(ax_hist, S(i).xco2, 80,...
        'FaceColor',  yearColors(i,:),...
        'FaceAlpha',  0.45,...
        'EdgeColor',  'none',...
        'DisplayName',sprintf('%s  \\mu=%.3f ppm', S(i).label, S(i).mean));
end
for i=1:nFiles
    xline(ax_hist, S(i).mean,'--','LineWidth',1.8,'Color',yearColors(i,:),...
        'Label',sprintf('%.2f',S(i).mean),...
        'LabelHorizontalAlignment','right','FontSize',8);
end
hold(ax_hist,'off');

xlabel(ax_hist,'XCO_2 (ppm)','FontSize',12,'Color','k');
ylabel(ax_hist,'Sounding count','FontSize',12,'Color','k');
title(ax_hist,'Global XCO_2 Distribution — OCO-2 | 2019–2025',...
    'FontWeight','bold','FontSize',13,'Color','k');
ax_hist.XColor='k'; ax_hist.YColor='k'; ax_hist.FontSize=11;
legend(ax_hist,'Location','northwest','FontSize',9);
grid(ax_hist,'on');

%% ---------------------------------------------------------------
%  CONSOLE SUMMARY
%% ---------------------------------------------------------------

fprintf('\n');
fprintf('================================================================\n');
fprintf('        OCO-2 GLOBAL XCO2 SUMMARY — 2019 to 2025\n');
fprintf('================================================================\n');
fprintf('%-10s  %8s  %8s  %8s  %8s  %16s\n',...
    'Date','Mean','Median','Std','P95','Change vs 2019');
fprintf('%s\n',repmat('-',1,70));
baseline = S(1).mean;
for i=1:nFiles
    delta = S(i).mean - baseline;
    fprintf('%-10s  %8.3f  %8.3f  %8.3f  %8.3f  %+14.3f ppm\n',...
        shortLabels{i},S(i).mean,S(i).median,S(i).std,S(i).p95,delta);
end

p_trend = polyfit(years, meanVals, 1);
fprintf('\nLinear trend : %+.4f ppm/year\n', p_trend(1));
fprintf('Total change : %+.3f ppm (2019 to 2025)\n', S(end).mean-S(1).mean);
fprintf('\nAll 4 figures generated successfully.\n');
