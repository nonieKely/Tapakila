import { create } from "zustand";
import User from "../../../Back-end/api/entity/User.js";

interface UserStore {
  user: User | null;
  setUser: (user: User | null) => void;
}

export const useUserStore = create<UserStore>((set) => ({
    user: null,
    setUser: (user) => set({ user }),
  }));