
// Operators Page Flags
int operatorSearchDelegate = 2;

bool operatorDisplayAvatar = true;
bool operatorDisplayPotrait = false;
void setDisplayChip (bool newState, String chip) {
  chip != 'avatar' ? operatorDisplayAvatar = false : operatorDisplayAvatar = true;
  chip != 'potrait' ? operatorDisplayPotrait = false : operatorDisplayPotrait = true;
}
