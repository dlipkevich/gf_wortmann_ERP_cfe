﻿
Процедура ВыполнитьСопоставлениеПрОрдеровИЗаявокНаВозврат(РезультатВыполнения) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапросаДанные();
	ПакетРезультатов = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	Связи = ПакетРезультатов[0].Выбрать(); //выборка
	СвязиССовпадающимКоличеством = ПакетРезультатов[7].Выгрузить(); //таблица значений
	СопоставленныеКМЗаявкиОрдера = ПакетРезультатов[8].Выгрузить(); //таблица значений
	СоставТоварыДокументовСводно = ПакетРезультатов[6].Выгрузить(); //таблица значений
	МассивСообщений = Новый Структура();
	Пока Связи.Следующий() Цикл
		
		тзТовары = Связи["Заявка"]["ВозвращаемыеТовары"].Выгрузить();
		Для каждого стрТЗ Из тзТовары Цикл
			стрТЗ["гф_ПринятСкладом"] = Истина;
			стрТЗ["гф_ДокументПриходныйОрдер"] = Связи["Ордер"]; // Галфинд_Домнышева 2023/04/25
		КонецЦикла;
		
		мКМОтсутствуютВЗаявке = Новый Массив;
		мКМОтсутствуетВОрдере = Новый Массив;
		мСообщений = Новый Массив;
		СтруктураСообщения = Новый Структура("Заявка, Ордер, мСообщений", Связи["Заявка"], Связи["Ордер"], мСообщений);
		СтрПоиска = Новый Структура("Заявка, Ордер", Связи["Заявка"], Связи["Ордер"]);
		
		КоличествоСвязиСоответствуют = Ложь;	
		КМСвязиСоответствуют = Истина;

		мСтрСовпадающиеСвязи = СвязиССовпадающимКоличеством.НайтиСтроки(СтрПоиска);
		
		Если мСтрСовпадающиеСвязи.Количество() = 1 Тогда
			// 1. Обработаем совпадающие по номенклатуре
			КоличествоСвязиСоответствуют = Истина;
		КонецЕсли;
		
		мСтрСопоставлениеКМ = СопоставленныеКМЗаявкиОрдера.НайтиСтроки(СтрПоиска);
		Если мСтрСопоставлениеКМ.Количество() > 0 Тогда
			Для каждого стрТЗ Из мСтрСопоставлениеКМ Цикл
				Если Не стрТЗ["ВОрдере"] ИЛИ Не стрТЗ["ВЗаявке"] Тогда
					КМСвязиСоответствуют = Ложь;	
					Шаблон = "Код маркировки: %1 присутствует только в %2";
					Текст = СтрШаблон(Шаблон, стрТЗ["КМ"], ?(стрТЗ["ВОрдере"], "ордере", "заявке"));
					СтруктураСообщения["мСообщений"].Добавить(Текст);
					Если Не стрТЗ["ВЗаявке"] Тогда
						мКМОтсутствуютВЗаявке.Добавить(стрТЗ["КМ"]);
					Иначе 
						мКМОтсутствуетВОрдере.Добавить(стрТЗ["КМ"]);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Если КоличествоСвязиСоответствуют И КМСвязиСоответствуют  Тогда
			ЗаписатьЗаявкуВПопытке(Связи["Заявка"], тзТовары, Истина);
			Продолжить;
		КонецЕсли;
		
		Если Не КМСвязиСоответствуют  Тогда
			Для каждого стрТз  Из тзТовары  Цикл
				Если мКМОтсутствуютВЗаявке.Найти(стрТз["гф_ПринятыеКМ"]) <> Неопределено Тогда
					стрТз["гф_ПринятСкладом"] = Ложь;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Если Не КоличествоСвязиСоответствуют Тогда
			мСтрокСоставыСводно = СоставТоварыДокументовСводно.НайтиСтроки(СтрПоиска);
			тзСопоставленныеКМ = СопоставленныеКМЗаявкиОрдера.Скопировать(мСтрСопоставлениеКМ);
			Для каждого стрСоставы Из мСтрокСоставыСводно Цикл
				Если Не стрСоставы["КоличествоУпаковокСовпадает"] Тогда
					стрПоискаВЗаявке = Новый Структура("Номенклатура, Характеристика",
					стрСоставы["Номенклатура"], стрСоставы["Характеристика"]);
					колЗаявка = стрСоставы["КоличествоУпаковокЗаявка"];
					колОрдер = стрСоставы["КоличествоУпаковокОрдер"];
					
					Шаблон = "По номенклатуре %1 и характеристике %2 в ордере: %3 упак., в заявке на возврат: %4 упак.";
					Текст = СтрШаблон(Шаблон, стрСоставы["Номенклатура"], стрСоставы["Характеристика"], колОрдер, колЗаявка);
					СтруктураСообщения["мСообщений"].Добавить(Текст);
					
					мСтрокТовары = тзТовары.НайтиСтроки(стрПоискаВЗаявке);
					Если КМСвязиСоответствуют Тогда
						Если колОрдер = 0 Тогда
							Для каждого стрТовары Из мСтрокТовары Цикл
								стрТовары["гф_ПринятСкладом"] = Ложь; //не можем однозначно сопоставить строку заявки и КМ ордера 
								стрТовары["гф_ДокументПриходныйОрдер"] = Документы.ПриходныйОрдерНаТовары.ПустаяСсылка(); // Галфинд_Домнышева 2023/04/20
							КонецЦикла;
						Иначе
							сч = колОрдер;
							Для каждого стрТовары Из мСтрокТовары Цикл
								Если сч > 0 Тогда
									индекс = мКМОтсутствуетВОрдере.Найти(стрТовары["гф_ПринятыеКМ"]);
									Если индекс <> Неопределено Тогда
										стрТовары["гф_ПринятСкладом"] = Ложь;
										стрТовары["гф_ДокументПриходныйОрдер"] = Документы.ПриходныйОрдерНаТовары.ПустаяСсылка();// Галфинд_Домнышева 2023/04/20
									КонецЕсли;	
								КонецЕсли;
								сч = сч -1;
							КонецЦикла;
						КонецЕсли;
					Иначе
						Для каждого стрТовары Из мСтрокТовары Цикл
							индекс = мКМОтсутствуетВОрдере.Найти(стрТовары["гф_ПринятыеКМ"]);
							Если индекс <> Неопределено Тогда
								стрТовары["гф_ПринятСкладом"] = Ложь;
								стрТовары["гф_ДокументПриходныйОрдер"] = Документы.ПриходныйОрдерНаТовары.ПустаяСсылка(); // Галфинд_Домнышева 2023/04/20
								Шаблон = "стр %1: Код маркировки %2 есть в заявке на возврат, но не найден в ордере";
								Текст = СтрШаблон(Шаблон, стрТовары["НомерСтроки"],мКМОтсутствуетВОрдере[индекс]);
								СтруктураСообщения["мСообщений"].Добавить(Текст);
							КонецЕсли;
						КонецЦикла;	
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		ЗаписатьЗаявкуВПопытке(Связи["Заявка"], тзТовары, Ложь);
		
		МассивСообщений.Вставить(СтруктураСообщения);
	КонецЦикла;
КонецПроцедуры

Функция ТекстЗапросаДанные()
	
	ТекстЗапроса = "
|ВЫБРАТЬ
|	Заявка.Ссылка КАК Заявка,
|	Ордер.Ссылка КАК Ордер
|ПОМЕСТИТЬ Связи
|ИЗ
|	Документ.ПриходныйОрдерНаТовары КАК Ордер
|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаявкаНаВозвратТоваровОтКлиента КАК Заявка
|		ПО (Заявка.Ссылка = Ордер.Распоряжение)
|ГДЕ
|	Ордер.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыПриходныхОрдеров.Принят)
|	И Заявка.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КВозврату)
|	И Заявка.Проведен
|	И Ордер.Проведен
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	Связи.Заявка КАК Заявка,
|	Связи.Ордер КАК Ордер,
|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.Номенклатура КАК Номенклатура,
|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.Характеристика КАК Характеристика,
|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.гф_ПринятыеКМ КАК ПринятыйКМ,
|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.гф_ПринятСкладом КАК ПринятСкладом
|ПОМЕСТИТЬ ЗаявкаТовары
|ИЗ
|	Связи КАК Связи
|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаявкаНаВозвратТоваровОтКлиента.ВозвращаемыеТовары КАК ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары
|		ПО Связи.Заявка = ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.Ссылка
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ЗаявкаТовары.Заявка КАК Заявка,
|	ЗаявкаТовары.Ордер КАК Ордер,
|	ЗаявкаТовары.Номенклатура КАК Номенклатура,
|	ЗаявкаТовары.Характеристика КАК Характеристика,
|	СУММА(1) КАК Количество,
|	СУММА(1) КАК КоличествоУпаковок
|ПОМЕСТИТЬ ЗаявкаТоварыСвернуто
|ИЗ
|	ЗаявкаТовары КАК ЗаявкаТовары
|
|СГРУППИРОВАТЬ ПО
|	ЗаявкаТовары.Заявка,
|	ЗаявкаТовары.Ордер,
|	ЗаявкаТовары.Номенклатура,
|	ЗаявкаТовары.Характеристика
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ЗаявкаТовары.Ордер КАК Ордер,
|	ЗаявкаТовары.Заявка КАК Заявка,
|	ЗаявкаТовары.ПринятыйКМ КАК КМ,
|	ЗаявкаТовары.ПринятыйКМ.Номенклатура КАК НоменклатураКМ,
|	ЗаявкаТовары.ПринятыйКМ.Характеристика КАК ХарактеристикаКМ
|ПОМЕСТИТЬ КМЗаявки
|ИЗ
|	ЗаявкаТовары КАК ЗаявкаТовары
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	Связи.Заявка КАК Заявка,
|	Связи.Ордер КАК Ордер,
|	ПриходныйОрдерНаТоварыТовары.Номенклатура КАК Номенклатура,
|	ПриходныйОрдерНаТоварыТовары.Характеристика КАК Характеристика,
|	СУММА(ПриходныйОрдерНаТоварыТовары.Количество) КАК Количество,
|	СУММА(ПриходныйОрдерНаТоварыТовары.КоличествоУпаковок) КАК КоличествоУпаковок
|ПОМЕСТИТЬ ОрдерТоварыСвернуто
|ИЗ
|	Связи КАК Связи
|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.Товары КАК ПриходныйОрдерНаТоварыТовары
|		ПО Связи.Ордер = ПриходныйОрдерНаТоварыТовары.Ссылка
|
|СГРУППИРОВАТЬ ПО
|	Связи.Заявка,
|	Связи.Ордер,
|	ПриходныйОрдерНаТоварыТовары.Номенклатура,
|	ПриходныйОрдерНаТоварыТовары.Характеристика
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	Связи.Ордер КАК Ордер,
|	Связи.Заявка КАК Заявка,
|	ШтрихкодыОрдера.ШтрихкодУпаковки КАК КМ,
|	ШтрихкодыОрдера.ШтрихкодУпаковки.Номенклатура КАК НоменклатураКМ,
|	ШтрихкодыОрдера.ШтрихкодУпаковки.Характеристика КАК ХарактеристикаКМ
|ПОМЕСТИТЬ КМОрдера
|ИЗ
|	Связи КАК Связи
|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.ШтрихкодыУпаковок КАК ШтрихкодыОрдера
|		ПО Связи.Ордер = ШтрихкодыОрдера.Ссылка
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ЗаявкаТоварыСвернуто.Заявка КАК Заявка,
|	ЗаявкаТоварыСвернуто.Ордер КАК Ордер,
|	ЗаявкаТоварыСвернуто.Номенклатура КАК Номенклатура,
|	ЗаявкаТоварыСвернуто.Характеристика КАК Характеристика,
|	ЕСТЬNULL(ЗаявкаТоварыСвернуто.Количество, 0) КАК КоличествоЗаявка,
|	ЕСТЬNULL(ОрдерТоварыСвернуто.Количество, 0) КАК КоличествоОрдер,
|	ЕСТЬNULL(ЗаявкаТоварыСвернуто.КоличествоУпаковок, 0) КАК КоличествоУпаковокЗаявка,
|	ЕСТЬNULL(ОрдерТоварыСвернуто.КоличествоУпаковок, 0) КАК КоличествоУпаковокОрдер,
|	ВЫБОР
|		КОГДА ЕСТЬNULL(ЗаявкаТоварыСвернуто.Количество, 0) = ЕСТЬNULL(ОрдерТоварыСвернуто.Количество, 0)
|			ТОГДА ИСТИНА
|		ИНАЧЕ ЛОЖЬ
|	КОНЕЦ КАК КоличествоСовпадает,
|	ВЫБОР
|		КОГДА ЕСТЬNULL(ЗаявкаТоварыСвернуто.КоличествоУпаковок, 0) = ЕСТЬNULL(ОрдерТоварыСвернуто.КоличествоУпаковок, 0)
|			ТОГДА ИСТИНА
|		ИНАЧЕ ЛОЖЬ
|	КОНЕЦ КАК КоличествоУпаковокСовпадает
|ПОМЕСТИТЬ СоставТоваровДокументовСводно
|ИЗ
|	ЗаявкаТоварыСвернуто КАК ЗаявкаТоварыСвернуто
|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ОрдерТоварыСвернуто КАК ОрдерТоварыСвернуто
|		ПО ЗаявкаТоварыСвернуто.Заявка = ОрдерТоварыСвернуто.Заявка
|			И ЗаявкаТоварыСвернуто.Ордер = ОрдерТоварыСвернуто.Ордер
|			И ЗаявкаТоварыСвернуто.Номенклатура = ОрдерТоварыСвернуто.Номенклатура
|			И ЗаявкаТоварыСвернуто.Характеристика = ОрдерТоварыСвернуто.Характеристика
|
|ОБЪЕДИНИТЬ ВСЕ
|
|ВЫБРАТЬ
|	ЗаявкаТоварыСвернуто.Заявка,
|	ЗаявкаТоварыСвернуто.Ордер,
|	ЗаявкаТоварыСвернуто.Номенклатура,
|	ЗаявкаТоварыСвернуто.Характеристика,
|	ЕСТЬNULL(ЗаявкаТоварыСвернуто.Количество, 0),
|	ЕСТЬNULL(ОрдерТоварыСвернуто.Количество, 0),
|	ЕСТЬNULL(ЗаявкаТоварыСвернуто.КоличествоУпаковок, 0),
|	ЕСТЬNULL(ОрдерТоварыСвернуто.КоличествоУпаковок, 0),
|	ВЫБОР
|		КОГДА ЕСТЬNULL(ЗаявкаТоварыСвернуто.Количество, 0) = ЕСТЬNULL(ОрдерТоварыСвернуто.Количество, 0)
|			ТОГДА ИСТИНА
|		ИНАЧЕ ЛОЖЬ
|	КОНЕЦ,
|	ВЫБОР
|		КОГДА ЕСТЬNULL(ЗаявкаТоварыСвернуто.КоличествоУпаковок, 0) = ЕСТЬNULL(ОрдерТоварыСвернуто.КоличествоУпаковок, 0)
|			ТОГДА ИСТИНА
|		ИНАЧЕ ЛОЖЬ
|	КОНЕЦ
|ИЗ
|	ЗаявкаТоварыСвернуто КАК ЗаявкаТоварыСвернуто
|		ЛЕВОЕ СОЕДИНЕНИЕ ОрдерТоварыСвернуто КАК ОрдерТоварыСвернуто
|		ПО ЗаявкаТоварыСвернуто.Заявка = ОрдерТоварыСвернуто.Заявка
|			И ЗаявкаТоварыСвернуто.Ордер = ОрдерТоварыСвернуто.Ордер
|			И ЗаявкаТоварыСвернуто.Номенклатура = ОрдерТоварыСвернуто.Номенклатура
|			И ЗаявкаТоварыСвернуто.Характеристика = ОрдерТоварыСвернуто.Характеристика
|ГДЕ
|	ОрдерТоварыСвернуто.Номенклатура ЕСТЬ NULL
|
|ОБЪЕДИНИТЬ ВСЕ
|
|ВЫБРАТЬ
|	ОрдерТоварыСвернуто.Заявка,
|	ОрдерТоварыСвернуто.Ордер,
|	ОрдерТоварыСвернуто.Номенклатура,
|	ОрдерТоварыСвернуто.Характеристика,
|	ЕСТЬNULL(ЗаявкаТоварыСвернуто.Количество, 0),
|	ЕСТЬNULL(ОрдерТоварыСвернуто.Количество, 0),
|	ЕСТЬNULL(ЗаявкаТоварыСвернуто.КоличествоУпаковок, 0),
|	ЕСТЬNULL(ОрдерТоварыСвернуто.КоличествоУпаковок, 0),
|	ВЫБОР
|		КОГДА ЕСТЬNULL(ЗаявкаТоварыСвернуто.Количество, 0) = ЕСТЬNULL(ОрдерТоварыСвернуто.Количество, 0)
|			ТОГДА ИСТИНА
|		ИНАЧЕ ЛОЖЬ
|	КОНЕЦ,
|	ВЫБОР
|		КОГДА ЕСТЬNULL(ЗаявкаТоварыСвернуто.КоличествоУпаковок, 0) = ЕСТЬNULL(ОрдерТоварыСвернуто.КоличествоУпаковок, 0)
|			ТОГДА ИСТИНА
|		ИНАЧЕ ЛОЖЬ
|	КОНЕЦ
|ИЗ
|	ЗаявкаТоварыСвернуто КАК ЗаявкаТоварыСвернуто
|		ПРАВОЕ СОЕДИНЕНИЕ ОрдерТоварыСвернуто КАК ОрдерТоварыСвернуто
|		ПО ЗаявкаТоварыСвернуто.Заявка = ОрдерТоварыСвернуто.Заявка
|			И ЗаявкаТоварыСвернуто.Ордер = ОрдерТоварыСвернуто.Ордер
|			И ЗаявкаТоварыСвернуто.Номенклатура = ОрдерТоварыСвернуто.Номенклатура
|			И ЗаявкаТоварыСвернуто.Характеристика = ОрдерТоварыСвернуто.Характеристика
|ГДЕ
|	ЗаявкаТоварыСвернуто.Номенклатура ЕСТЬ NULL
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	СоставТоваровДокументовСводно.Заявка КАК Заявка,
|	СоставТоваровДокументовСводно.Ордер КАК Ордер,
|	МИНИМУМ(СоставТоваровДокументовСводно.КоличествоУпаковокСовпадает) КАК КоличествоУпаковокСовпадает,
|	МИНИМУМ(СоставТоваровДокументовСводно.КоличествоСовпадает) КАК КоличествоСовпадает
|ПОМЕСТИТЬ СвязиССовпадающимКоличеством
|ИЗ
|	СоставТоваровДокументовСводно КАК СоставТоваровДокументовСводно
|
|СГРУППИРОВАТЬ ПО
|	СоставТоваровДокументовСводно.Заявка,
|	СоставТоваровДокументовСводно.Ордер
|
|ИМЕЮЩИЕ
|	МИНИМУМ(СоставТоваровДокументовСводно.КоличествоУпаковокСовпадает) = ИСТИНА И
|	МИНИМУМ(СоставТоваровДокументовСводно.КоличествоСовпадает) = ИСТИНА
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ВложенныйЗапрос.КМ КАК КМ,
|	ВложенныйЗапрос.ВОрдере КАК ВОрдере,
|	ВложенныйЗапрос.ВЗаявке КАК ВЗаявке,
|	ВложенныйЗапрос.Заявка КАК Заявка,
|	ВложенныйЗапрос.Ордер КАК Ордер 
|	Поместить СопоставлениеКМЗаявкиОрдера
|ИЗ
|	(ВЫБРАТЬ
|		КМЗаявки.КМ КАК КМ,
|		ИСТИНА КАК ВОрдере,
|		ИСТИНА КАК ВЗаявке,
|		КМЗаявки.Ордер КАК Ордер,
|		КМЗаявки.Заявка КАК Заявка
|	ИЗ
|		КМЗаявки КАК КМЗаявки
|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ КМОрдера КАК КМОрдера
|			ПО КМЗаявки.Ордер = КМОрдера.Ордер
|				И КМЗаявки.Заявка = КМОрдера.Заявка
|				И КМЗаявки.КМ = КМОрдера.КМ
|	
|	ОБЪЕДИНИТЬ ВСЕ
|	
|	ВЫБРАТЬ
|		КМЗаявки.КМ,
|		ЛОЖЬ,
|		ИСТИНА,
|		КМЗаявки.Ордер,
|		КМЗаявки.Заявка
|	ИЗ
|		КМЗаявки КАК КМЗаявки
|			ЛЕВОЕ СОЕДИНЕНИЕ КМОрдера КАК КМОрдера
|			ПО КМЗаявки.Ордер = КМОрдера.Ордер
|				И КМЗаявки.Заявка = КМОрдера.Заявка
|				И КМЗаявки.КМ = КМОрдера.КМ
|	ГДЕ
|		КМОрдера.КМ ЕСТЬ NULL
|	
|	ОБЪЕДИНИТЬ ВСЕ
|	
|	ВЫБРАТЬ
|		КМОрдера.КМ,
|		ИСТИНА,
|		ЛОЖЬ,
|		КМЗаявки.Ордер,
|		КМЗаявки.Заявка
|	ИЗ
|		КМОрдера КАК КМОрдера
|			ЛЕВОЕ СОЕДИНЕНИЕ КМЗаявки КАК КМЗаявки
|			ПО (КМЗаявки.Ордер = КМОрдера.Ордер)
|				И (КМЗаявки.Заявка = КМОрдера.Заявка)
|				И (КМЗаявки.КМ = КМОрдера.КМ)
|	ГДЕ
|		КМЗаявки.КМ ЕСТЬ NULL) КАК ВложенныйЗапрос";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Процедура ЗаписатьЗаявкуВПопытке(ЗаявкаСсылка, Товары, ПеревестиСтатус = Ложь)
	
	обЗаявка = ЗаявкаСсылка.ПолучитьОбъект();
	Если обЗаявка <> Неопределено Тогда
		обЗаявка.ДополнительныеСвойства.Вставить("гф_НеСоздаватьПриходныйОрдерПриПроведении", Истина);
		обЗаявка["ВозвращаемыеТовары"].Загрузить(Товары);
		Если ПеревестиСтатус 
			И обЗаявка.Статус = Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КВозврату Тогда
			обЗаявка.Статус = Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КОбеспечению;
		КонецЕсли;
		РежимЗаписи = ?(обЗаявка.Проведен, РежимЗаписиДокумента.Проведение,
		РежимЗаписиДокумента.Запись);
		Попытка
			обЗаявка.Записать(РежимЗаписи);
		Исключение
			ТекстОшибки = ОписаниеОшибки();
			ЗаписьЖурналаРегистрации("РегламентнаоеСопоставлениеЗаявокНаВозвратИОрдеров", 
			УровеньЖурналаРегистрации.Предупреждение, , , ТекстОшибки);
		КонецПопытки;	
	КонецЕсли;
	
КонецПроцедуры
