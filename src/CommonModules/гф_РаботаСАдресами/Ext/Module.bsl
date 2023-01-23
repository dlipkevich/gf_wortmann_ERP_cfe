﻿Функция ИндексАдресаКонтактнойИнформации(АдресДоставкиЗначение) Экспорт

	Возврат РаботаСАдресами.СведенияОбАдресе(АдресДоставкиЗначение).Индекс;

КонецФункции

Функция ВыделитьПодстрокуПоНомеруРазряда(ИсходнаяСтрока, РазделительРазрядов, НомерРазряда) Экспорт
	
	НомерПрохода = 1;
	ИзменяемаяСтрока = ИсходнаяСтрока;
	ПозицияРазделителя = Найти(ИзменяемаяСтрока,РазделительРазрядов);
	Результат = Лев(ИзменяемаяСтрока,ПозицияРазделителя-1);
	Если НомерРазряда = НомерПрохода Тогда
		Возврат Результат;
	КонецЕсли;
	
	Пока ПозицияРазделителя > 0 Цикл  
		Результат = Лев(ИзменяемаяСтрока,ПозицияРазделителя-1);
		ИзменяемаяСтрока = Прав(ИзменяемаяСтрока,СтрДлина(ИзменяемаяСтрока)-ПозицияРазделителя);
		ПозицияРазделителя = Найти(ИзменяемаяСтрока,РазделительРазрядов);
		Если НомерРазряда = НомерПрохода Тогда
			Возврат Результат;
		КонецЕсли;
		НомерПрохода = НомерПрохода + 1;
	КонецЦикла;

	Возврат Результат;

КонецФункции
