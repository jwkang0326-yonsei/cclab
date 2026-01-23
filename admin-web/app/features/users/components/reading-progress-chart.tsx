
import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis, CartesianGrid } from "recharts";

interface ReadingData {
    name: string;
    total: number;
}

interface ReadingProgressChartProps {
    data: ReadingData[];
}

export function ReadingProgressChart({ data }: ReadingProgressChartProps) {
    return (
        <div className="rounded-xl border bg-card text-card-foreground shadow col-span-4">
            <div className="p-6 flex flex-col space-y-0.5">
                <h3 className="font-semibold leading-none tracking-tight">Weekly Reading Progress</h3>
                <p className="text-sm text-muted-foreground">Chapters read over time</p>
            </div>
            <div className="p-6 pt-0 pl-2">
                <ResponsiveContainer width="100%" height={350}>
                    <LineChart data={data}>
                        <XAxis
                            dataKey="name"
                            stroke="#888888"
                            fontSize={12}
                            tickLine={false}
                            axisLine={false}
                        />
                        <YAxis
                            stroke="#888888"
                            fontSize={12}
                            tickLine={false}
                            axisLine={false}
                            tickFormatter={(value) => `${value}`}
                        />
                        <CartesianGrid strokeDasharray="3 3" vertical={false} />
                        <Tooltip
                            contentStyle={{ borderRadius: '8px', border: '1px solid #e2e8f0' }}
                        />
                        <Line
                            type="monotone"
                            dataKey="total"
                            stroke="#8884d8"
                            strokeWidth={2}
                            activeDot={{ r: 8 }}
                        />
                    </LineChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
}
