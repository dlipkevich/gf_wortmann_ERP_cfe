﻿
#Область ПрограммныйИнтерфейс

// #wortmann {
// #Движение КМ организаций
// описание вставки
// Галфинд Sakovich 2022/08/18
//
// Формирование движений типовых документов по рН гф_ДвижениеКодовМаркировкиОрганизации
// см. ПодпискиНаСобытия.гф_ОбработкаПроведенияДвижениеКодовМаркировкиОрганизации
// Параметры:
// Источник - ДокументОбъект - регистраторы регистра
// Отказ - Булево - отказ от записи документа
// РежимПроведения - ДокументОбъект.РежимПроведенияДокумента 
Процедура гф_ОбработкаПроведенияДвижениеКодовМаркировкиОрганизации(Источник, Отказ, РежимПроведения) Экспорт
	
	Движения = Источник.Движения.гф_ДвижениеКодовМаркировкиОрганизации;
	Движения.Записывать = Ложь;
	Ссылка = Источник.Ссылка;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.УпаковочныйЛист") Тогда
		Если Источник.Товары.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		
		ДокументПоставки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Источник.Ссылка, "гф_Поставка");
		Если Не ЗначениеЗаполнено(ДокументПоставки) Тогда
			Возврат;
		КонецЕсли;
		ИмяТаблицыПоставки = ОбщегоНазначения.ИмяТаблицыПоСсылке(ДокументПоставки);
		
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	УпЛист.Ссылка КАК Регистратор,
		|	УпЛист.Дата КАК Период,
		|	УпЛист.гф_Организация КАК Организация,
		|	УпЛист.гф_Агрегация КАК КМ,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество,
		|	ДокументПоставки.Склад КАК Склад
		|ИЗ
		|	Документ.УпаковочныйЛист КАК УпЛист
		|		ЛЕВОЕ СОЕДИНЕНИЕ " + ИмяТаблицыПоставки + " КАК ДокументПоставки
		|		ПО (УпЛист.гф_Поставка = ДокументПоставки.Ссылка)
		|ГДЕ
		|	УпЛист.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Источник.Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.МаркировкаТоваровИСМП") Тогда
		Если Источник.ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Склад = гф_ПолучитьСкладИзДокументаОснования(Источник.ДокументОснование);
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	Маркировка.Ссылка КАК Регистратор,
		|	Маркировка.Дата КАК Период,
		|	Маркировка.Организация КАК Организация,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество,
		|	&Склад КАК Склад
		|ИЗ
		|	Документ.МаркировкаТоваровИСМП КАК Маркировка
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.МаркировкаТоваровИСМП.ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Маркировка.Ссылка
		|ГДЕ
		|	Маркировка.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ВозвратТоваровОтКлиента") Тогда
		Если Источник.ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	ВозвратТоваровОтКлиента.Ссылка КАК Регистратор,
		|	ВозвратТоваровОтКлиента.Дата КАК Период,
		|	ВозвратТоваровОтКлиента.Склад КАК Склад,
		|	ВозвратТоваровОтКлиента.Организация КАК Организация,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество
		|ИЗ
		|	Документ.ВозвратТоваровОтКлиента КАК ВозвратТоваровОтКлиента
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратТоваровОтКлиента.ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО (Штрихкоды.Ссылка = ВозвратТоваровОтКлиента.Ссылка)
		|ГДЕ
		|	ВозвратТоваровОтКлиента.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход),
		|	ВозвратТоваровОтКлиента.Ссылка,
		|	ВозвратТоваровОтКлиента.Дата,
		|	ВозвратТоваровОтКлиента.Контрагент,
		|	ВозвратТоваровОтКлиента.Организация,
		|	Штрихкоды.ШтрихкодУпаковки,
		|	ЛОЖЬ,
		|	1
		|ИЗ
		|	Документ.ВозвратТоваровОтКлиента КАК ВозвратТоваровОтКлиента
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратТоваровОтКлиента.ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = ВозвратТоваровОтКлиента.Ссылка
		|ГДЕ
		|	ВозвратТоваровОтКлиента.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
		Если Источник.ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	Реализация.Контрагент КАК Склад,
		|	Реализация.Организация КАК Организация,
		|	Реализация.Ссылка КАК Регистратор,
		|	Реализация.Дата КАК Период,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК Реализация
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг.ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Реализация.Ссылка
		|ГДЕ
		|	Реализация.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход),
		|	Штрихкоды.ШтрихкодУпаковки,
		|	Реализация.Склад,
		|	Реализация.Организация,
		|	Реализация.Ссылка,
		|	Реализация.Дата,
		|	ЛОЖЬ,
		|	1
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК Реализация
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг.ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Реализация.Ссылка
		|ГДЕ
		|	Реализация.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ВнутреннееПотребление") Тогда
		Если Источник.гф_ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход) КАК ВидДвижения,
		|	Потребление.Ссылка КАК Регистратор,
		|	Потребление.Дата КАК Период,
		|	Потребление.Склад КАК Склад,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	Потребление.Организация КАК Организация,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество
		|ИЗ
		|	Документ.ВнутреннееПотребление КАК Потребление
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВнутреннееПотребление.гф_ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Потребление.Ссылка
		|ГДЕ
		|	Потребление.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.СписаниеНедостачТоваров") Тогда
		Если Источник.гф_ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход) КАК ВидДвижения,
		|	Списание.Ссылка КАК Регистратор,
		|	Списание.Дата КАК Период,
		|	Списание.Организация КАК Организация,
		|	Списание.Склад КАК Склад,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество
		|ИЗ
		|	Документ.СписаниеНедостачТоваров КАК Списание
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СписаниеНедостачТоваров.гф_ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Списание.Ссылка
		|ГДЕ
		|	Списание.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ПересортицаТоваров") Тогда
		Если Источник.гф_ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	Пересортица.Ссылка КАК Регистратор,
		|	Пересортица.Дата КАК Период,
		|	Пересортица.Организация КАК Организация,
		|	Пересортица.Склад КАК Склад,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество
		|ИЗ
		|	Документ.ПересортицаТоваров КАК Пересортица
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПересортицаТоваров.гф_ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Пересортица.Ссылка
		|ГДЕ
		|	Пересортица.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход),
		|	Пересортица.Ссылка,
		|	Пересортица.Дата,
		|	Пересортица.Организация,
		|	Пересортица.Склад,
		|	Штрихкоды.ШтрихкодУпаковки,
		|	ЛОЖЬ,
		|	1
		|ИЗ
		|	Документ.ПересортицаТоваров КАК Пересортица
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПересортицаТоваров.гф_ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Пересортица.Ссылка
		|ГДЕ
		|	Пересортица.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ПеремещениеТоваров") Тогда
		Если Источник.гф_ШтрихкодыУпаковок.Количество() = 0 Тогда
			Возврат;	
		КонецЕсли;
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	Перемещение.Ссылка КАК Регистратор,
		|	Перемещение.Дата КАК Период,
		|	Перемещение.Организация КАК Организация,
		|	Перемещение.СкладПолучатель КАК Склад,
		|	Штрихкоды.ШтрихкодУпаковки КАК КМ,
		|	ЛОЖЬ КАК Резерв,
		|	1 КАК Количество
		|ИЗ
		|	Документ.ПеремещениеТоваров КАК Перемещение
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров.гф_ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Перемещение.Ссылка
		|ГДЕ
		|	Перемещение.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход),
		|	Перемещение.Ссылка,
		|	Перемещение.Дата,
		|	Перемещение.Организация,
		|	Перемещение.СкладОтправитель,
		|	Штрихкоды.ШтрихкодУпаковки,
		|	ЛОЖЬ,
		|	1
		|ИЗ
		|	Документ.ПеремещениеТоваров КАК Перемещение
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров.гф_ШтрихкодыУпаковок КАК Штрихкоды
		|		ПО Штрихкоды.Ссылка = Перемещение.Ссылка
		|ГДЕ
		|	Перемещение.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Таблица = Результат.Выгрузить();
		Движения.Загрузить(Таблица);
	КонецЕсли;
	
	Движения.Записывать = Движения.Количество() > 0;
КонецПроцедуры

Процедура гф_АгрегироватьШтрихкодыУпаковокНоменклатуры(Ссылка) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	АгрегацияКМ.АртикулАгрегата КАК АртикулАгрегата,
	|	АгрегацияКМ.Агрегат КАК АгрегатСтрокой,
	|	АгрегацияКМ.КМ КАК КМ,
	|	ВЫБОР
	|		КОГДА Штрихкоды.Ссылка ЕСТЬ NULL
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК КМ_Найден,
	|	Агрегаты.Ссылка КАК НайденныйАгрегат,
	|	ВЫБОР
	|		КОГДА Агрегаты.Ссылка ЕСТЬ NULL
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК Агрегат_Найден,
	|	ВложШтрихкоды.Ссылка КАК КМСодержитсяВАгрегате
	|ИЗ
	|	Документ.гф_АгрегацияКМ.Товары КАК АгрегацияКМ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК Агрегаты
	|		ПО (АгрегацияКМ.Агрегат = Агрегаты.ЗначениеШтрихкода)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК Штрихкоды
	|		ПО (АгрегацияКМ.КМ = Штрихкоды.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ВложШтрихкоды
	|		ПО (АгрегацияКМ.КМ = ВложШтрихкоды.Штрихкод)
	|ГДЕ
	|	АгрегацияКМ.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	АгрегацияКМ.АртикулАгрегата,
	|	АгрегацияКМ.Агрегат,
	|	АгрегацияКМ.КМ,
	|	Агрегаты.Ссылка,
	|	Штрихкоды.Ссылка,
	|	ВложШтрихкоды.Ссылка";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Результат = Запрос.Выполнить();
	ТЗ = Результат.Выгрузить();
	вспТЗ = ТЗ.Скопировать(, "КМСодержитсяВАгрегате");
	вспТЗ.Свернуть("КМСодержитсяВАгрегате");
	Для каждого стрТЗ Из вспТЗ Цикл
		Если стрТЗ["КМСодержитсяВАгрегате"] = NULL Тогда
			Продолжить;
		КонецЕсли;
		ОбъектОчистки = стрТЗ["КМСодержитсяВАгрегате"].ПолучитьОбъект();
		Если ОбъектОчистки <> Неопределено Тогда
			СтрокиДляОчистки = ТЗ.НайтиСтроки(Новый Структура("КМСодержитсяВАгрегате", стрТЗ["КМСодержитсяВАгрегате"]));
			Штрихкоды = ОбъектОчистки.ВложенныеШтрихкоды.Выгрузить();
			мУдаляемых = Новый Массив;
			Для каждого Эл Из СтрокиДляОчистки Цикл
				УдаляемыеСтроки = Штрихкоды.НайтиСтроки(Новый Структура("Штрихкод", Эл["КМ"]));	
				Для каждого стрДляУдаления Из УдаляемыеСтроки Цикл
					мУдаляемых.Добавить(стрДляУдаления);
				КонецЦикла;
			КонецЦикла;
			Для каждого УдаляемаяСтрока Из мУдаляемых Цикл
				Штрихкоды.Удалить(УдаляемаяСтрока);
			КонецЦикла;	
			ОбъектОчистки.ВложенныеШтрихкоды.Загрузить(Штрихкоды);
			ОбъектОчистки.Записать();	
		КонецЕсли;
	КонецЦикла;
	вспТЗ = ТЗ.Скопировать(, "АгрегатСтрокой, НайденныйАгрегат");
	вспТЗ.Свернуть("АгрегатСтрокой, НайденныйАгрегат");
	
	Для каждого стрТЗ Из вспТЗ Цикл
		структураПоиска = Новый Структура("АгрегатСтрокой, НайденныйАгрегат", 
		стрТЗ["АгрегатСтрокой"], 
		стрТЗ["НайденныйАгрегат"]);
		строкиДляЗаполнения = ТЗ.НайтиСтроки(структураПоиска);
		
		Если стрТЗ["НайденныйАгрегат"] = NULL Тогда
			ОбъектШтрихкод = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();	
			ОбъектШтрихкод.ТипУпаковки = Перечисления.ТипыУпаковок.МультитоварнаяУпаковка;
			ОбъектШтрихкод.ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_128;
			ОбъектШтрихкод.ЗначениеШтрихкода = строкиДляЗаполнения[0]["АгрегатСтрокой"];
			ОбъектШтрихкод.гф_АктикулАгрегата = строкиДляЗаполнения[0]["АртикулАгрегата"];
		Иначе
			ОбъектШтрихкод = стрТЗ["НайденныйАгрегат"].ПолучитьОбъект();
			Если Не ЗначениеЗаполнено(ОбъектШтрихкод.гф_АктикулАгрегата) Тогда
				ОбъектШтрихкод.гф_АктикулАгрегата = строкиДляЗаполнения[0]["АртикулАгрегата"];	
			КонецЕсли;
		КонецЕсли;
		ОбъектШтрихкод.ВложенныеШтрихкоды.Очистить();
		Для каждого Эл Из строкиДляЗаполнения Цикл
			Если Эл["КМ_Найден"] Тогда
				нС = ОбъектШтрихкод.ВложенныеШтрихкоды.Добавить();
				нС.Штрихкод = Эл["КМ"];
			КонецЕсли;
		КонецЦикла;
		ОбъектШтрихкод.Записать();
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
// Ссылка - см.состав ОпределяемыйТип ОснованиеМаркировкаТоваровИСМП
Функция гф_ПолучитьСкладИзДокументаОснования(Ссылка) Экспорт
	Склад = Неопределено;
	ДокМетаданные = Ссылка.Метаданные();
	ИмяМетаданных = ДокМетаданные.Имя;
	Если ИмяМетаданных = "ОприходованиеИзлишковТоваров" 
		ИЛИ	ИмяМетаданных = "ПересчетТоваров"
		ИЛИ	ИмяМетаданных = "ПоступлениеОтПереработчика"
		ИЛИ	ИмяМетаданных = "ПриобретениеТоваровУслуг"
		ИЛИ	ИмяМетаданных = "ПрочееОприходованиеТоваров"
		ИЛИ	ИмяМетаданных = "СборкаТоваров" Тогда
		Склад = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "Склад");
	КонецЕсли;
	
	Если ИмяМетаданных = "ПроизводствоБезЗаказа" Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ВложенныйЗапрос.Склад КАК Склад,
		|	ВложенныйЗапрос.Ссылка КАК Ссылка
		|ИЗ
		|	(ВЫБРАТЬ
		|		ВЫРАЗИТЬ(ПроизводствоБезЗаказаВыходныеИзделия.Получатель КАК Справочник.Склады) КАК Склад,
		|		ПроизводствоБезЗаказаВыходныеИзделия.Ссылка КАК Ссылка
		|	ИЗ
		|		Документ.ПроизводствоБезЗаказа.ВыходныеИзделия КАК ПроизводствоБезЗаказаВыходныеИзделия
		|	ГДЕ
		|		ПроизводствоБезЗаказаВыходныеИзделия.Ссылка = &Ссылка
		|		И НЕ ВЫРАЗИТЬ(ПроизводствоБезЗаказаВыходныеИзделия.Получатель КАК Справочник.Склады) ЕСТЬ NULL
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		ВЫРАЗИТЬ(ЭтапПроизводства2_2ВыходныеИзделия.Получатель КАК Справочник.Склады),
		|		ЭтапПроизводства2_2ВыходныеИзделия.Ссылка
		|	ИЗ
		|		Документ.ЭтапПроизводства2_2.ВыходныеИзделия КАК ЭтапПроизводства2_2ВыходныеИзделия
		|	ГДЕ
		|		ЭтапПроизводства2_2ВыходныеИзделия.Ссылка = &Ссылка
		|		И НЕ ВЫРАЗИТЬ(ЭтапПроизводства2_2ВыходныеИзделия.Получатель КАК Справочник.Склады) ЕСТЬ NULL) КАК ВложенныйЗапрос
		|
		|СГРУППИРОВАТЬ ПО
		|	ВложенныйЗапрос.Склад,
		|	ВложенныйЗапрос.Ссылка";
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		Если Выборка.Количество() = 1  Тогда
			Выборка.Следующий();
			Склад = Выборка.Склад;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Склад;
	
КонецФункции // } #wortmann

#КонецОбласти