// shared/hooks/useMetrics.ts
import { useEffect, useState, useCallback } from "react";
import { fetchMetrics, MetricsResponse, MetricsError, clearMetricsCache } from "../utils/metrics-util";

type UseMetricsArgs = {
  since: string;      // YYYY-MM-DD
  until: string;      // YYYY-MM-DD
  excludeHolidays?: boolean;
  // cualquier otro filtro que el backend soporte (scope, org, enterprise, etc.)
  scope?: "organization" | "enterprise";
  githubOrg?: string;
  githubEnterprise?: string;
};

export function useMetrics(args: UseMetricsArgs) {
  const [data, setData] = useState<MetricsResponse | undefined>(undefined);
  const [isLoading, setLoading] = useState(false);
  const [apiError, setApiError] = useState<MetricsError | undefined>(undefined);

  const load = useCallback(async () => {
    setLoading(true);
    // importante: limpiamos error previo al nuevo intento (tal como sugiere el PR #250)
    setApiError(undefined);
    try {
      const res = await fetchMetrics(args.since, args.until, {
        excludeHolidays: args.excludeHolidays,
        scope: args.scope,
        githubOrg: args.githubOrg,
        githubEnterprise: args.githubEnterprise,
      });
      setData(res);
    } catch (e) {
      setApiError(e as MetricsError);
      setData(undefined);
    } finally {
      setLoading(false);
    }
  }, [args.since, args.until, args.excludeHolidays, args.scope, args.githubOrg, args.githubEnterprise]);

  useEffect(() => {
    load();
    // si cambias de tenant/org, quizá quieras limpiar cache:
    // return () => clearMetricsCache();
  }, [load]);

  return { data, isLoading, apiError, reload: load, clearCache: clearMetricsCache };
}
