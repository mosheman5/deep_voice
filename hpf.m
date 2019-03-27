function b_box_new = hpf(b_mat, low_f, f_vec, t_vec)
    box_f=(f_vec<=low_f & f_vec>=-2);
    box_t=(t_vec<=1000 & t_vec>=0.00001)';
    box_i=box_t(ones(length(box_f),1),:).*box_f(:,ones(1,length(box_t)));
    b_box_new=b_mat.*(box_i==0);
end