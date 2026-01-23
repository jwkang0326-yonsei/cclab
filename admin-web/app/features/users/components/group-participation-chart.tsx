
import { Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip } from "recharts";

interface GroupData {
    name: string;
    rate: number;
}

interface GroupParticipationChartProps {
    data: GroupData[];
}

export function GroupParticipationChart({ data }: GroupParticipationChartProps) {
    return (
        <div className="rounded-xl border bg-card text-card-foreground shadow col-span-3">
            <div className="p-6 flex flex-col space-y-0.5">
                <h3 className="font-semibold leading-none tracking-tight">Group Participation</h3>
                <p className="text-sm text-muted-foreground">Active members by group</p>
            </div>
            <div className="p-6 pt-0 pl-2">
                <ResponsiveContainer width="100%" height={350}>
                    <BarChart data={data}>
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
                            tickFormatter={(value) => `${value}%`}
                        />
                        <Tooltip
                            cursor={{ fill: 'transparent' }}
                            contentStyle={{ borderRadius: '8px', border: '1px solid #e2e8f0' }}
                        />
                        <Bar
                            dataKey="rate"
                            fill="#adfa1d"
                            radius={[4, 4, 0, 0]}
                        />
                    </BarChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
}
