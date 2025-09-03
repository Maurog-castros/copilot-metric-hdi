/**
 * GitHub Copilot API Date Validation Utilities
 * 
 * GitHub Copilot Metrics API tiene las siguientes restricciones:
 * - Máximo 100 días de rango histórico
 * - No permite fechas futuras
 * - Mínimo 1 día de rango
 * - Los datos históricos están limitados por la disponibilidad de GitHub
 */

export interface DateValidationResult {
  isValid: boolean;
  errors: string[];
  warnings: string[];
  adjustedDates?: {
    since: string;
    until: string;
  };
}

export interface DateRange {
  since: string;
  until: string;
}

// Constantes de la API de GitHub Copilot
export const GITHUB_COPILOT_LIMITS = {
  MAX_DAYS_RANGE: 100,
  MIN_DAYS_RANGE: 1,
  MAX_HISTORICAL_DAYS: 365, // Máximo histórico razonable
  FUTURE_DATE_BUFFER: 1 // Días de buffer para fechas futuras
} as const;

/**
 * Valida un rango de fechas para la API de GitHub Copilot
 */
export function validateGitHubCopilotDateRange(
  since: string,
  until: string,
  options: {
    allowFutureDates?: boolean;
    strictMode?: boolean;
  } = {}
): DateValidationResult {
  const { allowFutureDates = false, strictMode = true } = options;
  const errors: string[] = [];
  const warnings: string[] = [];

  try {
    // Parsear fechas
    const sinceDate = new Date(since + 'T00:00:00.000Z');
    const untilDate = new Date(until + 'T00:00:00.000Z');
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Validar que las fechas sean válidas
    if (isNaN(sinceDate.getTime())) {
      errors.push('Fecha de inicio inválida');
      return { isValid: false, errors, warnings };
    }

    if (isNaN(untilDate.getTime())) {
      errors.push('Fecha de fin inválida');
      return { isValid: false, errors, warnings };
    }

    // Validar orden de fechas
    if (sinceDate > untilDate) {
      errors.push('La fecha de inicio debe ser anterior a la fecha de fin');
      return { isValid: false, errors, warnings };
    }

    // Calcular diferencia en días
    const diffTime = untilDate.getTime() - sinceDate.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

    // Validar rango mínimo
    if (diffDays < GITHUB_COPILOT_LIMITS.MIN_DAYS_RANGE) {
      errors.push(`El rango mínimo debe ser de ${GITHUB_COPILOT_LIMITS.MIN_DAYS_RANGE} día`);
      return { isValid: false, errors, warnings };
    }

    // Validar rango máximo
    if (diffDays > GITHUB_COPILOT_LIMITS.MAX_DAYS_RANGE) {
      errors.push(`El rango máximo permitido es de ${GITHUB_COPILOT_LIMITS.MAX_DAYS_RANGE} días. Rango seleccionado: ${diffDays} días`);
      return { isValid: false, errors, warnings };
    }

    // Validar fechas futuras
    if (!allowFutureDates) {
      const futureBufferDate = new Date(today);
      futureBufferDate.setDate(today.getDate() + GITHUB_COPILOT_LIMITS.FUTURE_DATE_BUFFER);

      if (untilDate > futureBufferDate) {
        errors.push('No se pueden consultar fechas futuras');
        return { isValid: false, errors, warnings };
      }
    }

    // Validar límite histórico
    const maxHistoricalDate = new Date(today);
    maxHistoricalDate.setDate(today.getDate() - GITHUB_COPILOT_LIMITS.MAX_HISTORICAL_DAYS);

    if (sinceDate < maxHistoricalDate) {
      if (strictMode) {
        errors.push(`La fecha de inicio no puede ser anterior a ${maxHistoricalDate.toISOString().split('T')[0]} (${GITHUB_COPILOT_LIMITS.MAX_HISTORICAL_DAYS} días atrás)`);
        return { isValid: false, errors, warnings };
      } else {
        warnings.push(`La fecha de inicio (${since}) está muy atrás en el tiempo. GitHub puede no tener datos disponibles para fechas tan antiguas.`);
      }
    }

    // Validar que la fecha de inicio no sea demasiado antigua
    const veryOldDate = new Date(today);
    veryOldDate.setDate(today.getDate() - 730); // 2 años atrás

    if (sinceDate < veryOldDate) {
      warnings.push('La fecha de inicio es muy antigua. Los datos de GitHub Copilot pueden no estar disponibles para fechas anteriores a 2022.');
    }

    // Ajustar fechas si es necesario (modo no estricto)
    let adjustedDates: { since: string; until: string } | undefined;

    if (!strictMode && diffDays > GITHUB_COPILOT_LIMITS.MAX_DAYS_RANGE) {
      const adjustedSinceDate = new Date(untilDate);
      adjustedSinceDate.setDate(untilDate.getDate() - GITHUB_COPILOT_LIMITS.MAX_DAYS_RANGE + 1);
      
      const adjustedSince = adjustedSinceDate.toISOString().split('T')[0];
      adjustedDates = {
        since: adjustedSince || '',
        until: until
      };
      
      warnings.push(`Rango ajustado automáticamente a ${GITHUB_COPILOT_LIMITS.MAX_DAYS_RANGE} días para cumplir con los límites de la API`);
    }

    return {
      isValid: true,
      errors,
      warnings,
      adjustedDates
    };

  } catch (error) {
    errors.push(`Error validando fechas: ${error instanceof Error ? error.message : 'Error desconocido'}`);
    return { isValid: false, errors, warnings };
  }
}

/**
 * Obtiene el rango de fechas por defecto recomendado (últimos 28 días)
 */
export function getDefaultDateRange(): DateRange {
  const today = new Date();
  const defaultFromDate = new Date(today.getTime() - 27 * 24 * 60 * 60 * 1000);
  
  const since = defaultFromDate.toISOString().split('T')[0] || '';
  const until = today.toISOString().split('T')[0] || '';
  
  return {
    since,
    until
  };
}

/**
 * Obtiene el rango máximo permitido (últimos 100 días)
 */
export function getMaxAllowedDateRange(): DateRange {
  const today = new Date();
  const maxFromDate = new Date(today.getTime() - 99 * 24 * 60 * 60 * 1000);
  
  const since = maxFromDate.toISOString().split('T')[0] || '';
  const until = today.toISOString().split('T')[0] || '';
  
  return {
    since,
    until
  };
}

/**
 * Formatea un mensaje de error de validación para mostrar al usuario
 */
export function formatValidationMessage(result: DateValidationResult): string {
  if (result.isValid) {
    let message = 'Rango de fechas válido';
    if (result.warnings.length > 0) {
      message += `\n⚠️ Advertencias: ${result.warnings.join(', ')}`;
    }
    return message;
  } else {
    return `❌ Errores de validación:\n${result.errors.join('\n')}`;
  }
}

/**
 * Verifica si una fecha está dentro del rango permitido para la API
 */
export function isDateWithinAPILimits(date: string): boolean {
  try {
    const targetDate = new Date(date + 'T00:00:00.000Z');
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const maxHistoricalDate = new Date(today);
    maxHistoricalDate.setDate(today.getDate() - GITHUB_COPILOT_LIMITS.MAX_HISTORICAL_DAYS);
    
    return targetDate >= maxHistoricalDate && targetDate <= today;
  } catch {
    return false;
  }
}
