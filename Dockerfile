FROM zasdfgbnm/archlinux-yaourt

# setup
USER root
COPY yaourt pacman /
COPY zshrc /etc/zsh/
COPY locale.gen /etc/locale.gen

# RUN /select-mirrors.sh
RUN pacman -Sy --noconfirm archlinux-keyring
# -S 安装 -y 更新list u=update
RUN pacman -Syu --noconfirm
# --noconfirm 不需要输入 yes or no
RUN pacman -S --noconfirm man-db man-pages
RUN pacman -S --noconfirm base
RUN locale-gen
RUN pacman -S --noconfirm $(grep '^\w.*' /pacman)

# install packages
USER user
RUN  yaourt -Syua --noconfirm || true
RUN for i in $(grep '^\w.*' /yaourt); do yaourt -S --noconfirm $i || true; done

# grep '^\w.*' 过滤

USER root

# setting up services
RUN systemctl enable sshd

# setting up sshd
RUN sed -i 's/.*PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
# sed 为 command， 把/etc/ssh/sshd_config文件进行替换，s/正则表达式/替换的内容/g

# setting up mkinitcpio
RUN sed -i 's/archlinux\/base/zdong1995\/mypc/g' /etc/docker-btrfs.json
RUN perl -i -p -e 's/(?<=^HOOKS=\()(.*)(?=\))/$1 docker-btrfs/g' /etc/mkinitcpio.conf

# copy gen_boot
COPY gen_boot /usr/bin
# /usr/bin 是一个 default path, 在里面的命令不需要输入 path 即可运行