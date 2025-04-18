export default async function getUserReservations(userId: string) {
    const res = await fetch(`http://localhost:3001/users/${userId}/reservations`, { next: { revalidate: 60 } });
  
    if (!res.ok) throw new Error("Erreur lors du chargement des données");
    
    return await res.json()
  }