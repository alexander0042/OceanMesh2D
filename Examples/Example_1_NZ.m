% Example_1_NZ: Mesh the South Island of New Zealand

clearvars; clc; close all

PREFIX = '1_NZ';

%% STEP 1: set mesh extents and set parameters for mesh.
bbox = [
    166 176         % lon_min lon_max
    -48 -40         % lat_min lat_max
    ];
min_el = 1e3;       % minimum resolution in meters.
max_el = 100e3;     % maximum resolution in meters.
max_el_ns = 5e3;    % maximum resolution nearshore in meters.
grade = 0.35;       % mesh grade in decimal percent.
R = 3;              % number of elements to resolve feature width.

%% STEP 2: specify geographical datasets and process the geographical data
% to be used later with other OceanMesh classes...
coastline = 'GSHHS_f_L1';
gdat = geodata('shp',coastline,'bbox',bbox,'h0',min_el);

%% STEP 3: create an edge function class
fh = edgefx(...
    'geodata',gdat,...
    'fs',R,'max_el_ns',max_el_ns,...
    'max_el',max_el,'g',grade);

%% STEP 4: Pass your edgefx class object along with some meshing options and
% build the mesh...
mshopts = meshgen('ef',fh,'bou',gdat,'plot_on',1,'nscreen',5,'proj','trans');
mshopts = mshopts.build;

%% STEP 5: Plot it and write a triangulation fort.14 compliant file to disk.
% Get out the msh class and put on nodestrings
m = mshopts.grd;
m = make_bc(m,'auto',gdat,'distance'); % make the boundary conditions
plot(m,'type','bd');

%% STEP 6: Example of plotting a subdomain with bcs
bbox_s =  [172 176; -42 -39];
plot(m,'type','bd','subdomain',bbox_s);

%% Export plots
figs = get(0,'children');
for f = 1:numel(figs)
    fname = sprintf('%s_plot%i',PREFIX,figs(f).Number);
    print(figs(f).Number,fname,'-dpng','-r200');
end

%% Save mesh files
% Save as a msh class
save(sprintf('%s_msh.mat',PREFIX),'m');
% Write an ADCIRC fort.14 compliant file to disk.
write(m,sprintf('%s_mesh',PREFIX))
