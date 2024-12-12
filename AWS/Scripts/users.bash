#!/bin/bash

# Group name
GROUP_NAME="fl_admin"



# Users to create (username:password)
declare -A USERS
USERS=(
  ["user1_r"]="R@rIuyt1u"
  ["user2_n"]="N@uiT3wau"
  ["user3_d"]="D@iuDt8ru"
)

# Create the group
echo "Creating group: $GROUP_NAME..."
aws iam create-group --group-name "$GROUP_NAME"

# Attach policies to the group (AmazonEC2ReadOnlyAccess for console access)
echo "Attaching policy to group: $GROUP_NAME..."
aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"

# Create and add users to the group
for USERNAME in "${!USERS[@]}"; do
  PASSWORD="${USERS[$USERNAME]}"
  echo "Creating user: $USERNAME..."
  aws iam create-user --user-name "$USERNAME"

  echo "Adding user $USERNAME to group $GROUP_NAME..."
  aws iam add-user-to-group --user-name "$USERNAME" --group-name "$GROUP_NAME"

  echo "Creating login profile for user $USERNAME..."
  aws iam create-login-profile --user-name "$USERNAME" --password "$PASSWORD"
done


echo "Creating login profile for admin user $ADMIN_USER..."
aws iam create-login-profile --user-name "$ADMIN_USER" --password "admin-password" --password-reset-required

echo "Setup complete!"
