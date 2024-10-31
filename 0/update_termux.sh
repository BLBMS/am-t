

if yes | pkg update; then
  echo -e "\n\e[92m  update OK  \n\e[0m"
else
  termux-change-repo
  yes | pkg update
  echo -e "\n\e[92m  update OK 2 \n\e[0m"
fi

if yes | pkg upgrade; then
  echo -e "\n\e[92m  upgrade OK  \n\e[0m"
else
  termux-change-repo
  yes | pkg upgrade
  echo -e "\n\e[92m  upgrade OK 2 \n\e[0m"
fi
