function [vox_src] = prepare_searchlight(brainsz,brainmask, src_res)
% get linear indices for searchlight corresponding to each voxel
% default resolution is 3

if isempty(src_res), src_res = 3; end
[mX,mY,mZ] = ndgrid(1:1:brainsz(1),1:1:brainsz(2),1:1:brainsz(3));

vox_src = cell(prod(brainsz),1);

%loop through brain; note - make sure not to use voxels outside brain...
for vx1 = 1:brainsz(1)
    for vx2 = 1:brainsz(2)
        for vx3 = 1:brainsz(3)

            if brainmask(vx1,vx2,vx3)==1

                idx = sub2ind(brainsz,vx1,vx2,vx3);

                I = sqrt((mX-vx1).^2 + (mY-vx2).^2 + (mZ-vx3).^2) < src_res;

                vox_src{idx} = sub2ind(size(I),find(I));

            end

        end
    end
end

fprintf('\nSearchlight prepared...')

end