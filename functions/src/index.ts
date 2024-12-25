import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

admin.initializeApp();
const apiKey = functions.config().google.maps.key;
if (!apiKey) {
    throw new Error("Google Maps API Key no encontrada en Firebase Config.");
}
interface Driver {
    id: string;
    location: string;
}

interface Client {
    id: string;
    homeLocation: string;
    workLocation: string;
}

interface GenerateRoutesData {
    drivers: Driver[];
    clients: Client[];
    maxClientsPerRoute: number;
}

export const generateRoutes = functions.https.onCall(
    async (
        request: functions.https.CallableRequest<GenerateRoutesData>
    ): Promise<{ routes: { driverId: string; clients: string[]; totalDuration: number }[] }> => {
        const { drivers, clients, maxClientsPerRoute } = request.data;

        if (!drivers || !clients || !maxClientsPerRoute) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Se requieren conductores, clientes y el número máximo de clientes por ruta."
            );
        }

        const routes = [];

        for (const driver of drivers) {
            const driverRoutes = [];
            const driverLocation = driver.location;

            for (const client of clients) {
                const clientHome = client.homeLocation;
                const clientWork = client.workLocation;

                try {
                    const response = await axios.get(
                        `https://maps.googleapis.com/maps/api/directions/json?origin=${driverLocation}&destination=${clientWork}&waypoints=${clientHome}&key=${apiKey}`
                    );

                    const routeInfo = response.data.routes[0];
                    driverRoutes.push({
                        clientId: client.id,
                        driverId: driver.id,
                        duration: routeInfo.legs[0].duration.value,
                        distance: routeInfo.legs[0].distance.value,
                    });

                    if (driverRoutes.length >= maxClientsPerRoute) break;
                } catch (error) {
                    console.error("Error al obtener la ruta:", error);
                }
            }

            routes.push({
                driverId: driver.id,
                clients: driverRoutes.map((r) => r.clientId),
                totalDuration: driverRoutes.reduce((sum, r) => sum + r.duration, 0),
            });
        }

        return { routes };
    }
);
