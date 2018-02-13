function temp=dyed(valid_box,temp)
for i=valid_box(2) : valid_box(4)
    for j=valid_box(1) : valid_box(3)
        
        temp(i,j) = temp(i,j) + 1;
    end
end
end

