﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДинСписок.Параметры.УстановитьЗначениеПараметра("ТестКонтрагент",
	Справочники.Контрагенты.НайтиПоНаименованию("Кириков Андрей Андреевич"));
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокНаСервере()
	
	ИспользованиеОтбораПоПериоду = ЗначениеЗаполнено(ОтборПоДатеЗаказов.ДатаОкончания)
	ИЛИ ЗначениеЗаполнено(ОтборПоДатеЗаказов.ДатаНачала);
	
	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(
	ДинСписок, 
	"НачалоПериода", 
	ОтборПоДатеЗаказов.ДатаНачала, 
	ИспользованиеОтбораПоПериоду);
	
	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(
	ДинСписок, 
	"КонецПериода", 
	?(Не ЗначениеЗаполнено(ОтборПоДатеЗаказов.ДатаОкончания),
	КонецДня(Дата('29991231')), КонецДня(ОтборПоДатеЗаказов.ДатаОкончания)), 
	ИспользованиеОтбораПоПериоду);
		
	СхемаКомпоновкиДанных = Элементы.ДинСписок.ПолучитьИсполняемуюСхемуКомпоновкиДанных();
    НастройкиКомпоновкиДанных = Элементы.ДинСписок.ПолучитьИсполняемыеНастройкиКомпоновкиДанных();
    
    КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
    МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, 
	НастройкиКомпоновкиДанных, , ,
	Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
    
    ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
    ПроцессорКомпоновки.Инициализировать(МакетКомпоновки);
    
    тз = Новый ТаблицаЗначений;
    
    ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
    ПроцессорВывода.УстановитьОбъект(тз);
    ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	Объект.ЗаказыКлиентов.Загрузить(тз);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписок(Команда)
	ОбновитьСписокНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьЗначениеПометки(Признак= Неопределено)
	
	Для каждого ЭлКоллекции Из Объект.ЗаказыКлиентов Цикл
		Если Признак= Неопределено Тогда
			ЭлКоллекции["Отметка"] = Не ЭлКоллекции["Отметка"];
		Иначе
			ЭлКоллекции["Отметка"] = Признак;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометку(Команда) 
	УстановитьЗначениеПометки(Истина);
КонецПроцедуры

&НаКлиенте
Процедура СнятьПометку(Команда)
	УстановитьЗначениеПометки(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ИнвертироватьПометку(Команда)
	УстановитьЗначениеПометки();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	//ОбновитьСписокНаСервере();
КонецПроцедуры

&НаСервере
Функция ВыбратьОстаткиДляВариантовДляОбработки()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	т.Организация КАК Организация,
	|	т.ВариантКомплектации КАК ВариантКомплектации,
	|	т.Поставщик КАК Поставщик,
	|	т.Склад КАК Склад,
	|	т.ЗаказКлиента КАК ЗаказКлиента,
	|	т.Отметка КАК Отметка
	|ПОМЕСТИТЬ вт
	|ИЗ
	|	&тз КАК т
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	тз.Организация КАК Организация,
	|	тз.ВариантКомплектации КАК ВариантКомплектации,
	|	тз.Поставщик КАК Поставщик,
	|	тз.Склад КАК Склад,
	|	тз.ЗаказКлиента КАК ЗаказКлиента,
	|	ИСТИНА КАК Отметка
	|ПОМЕСТИТЬ ИсходныеДанные
	|ИЗ
	|	вт КАК тз
	|ГДЕ
	|	тз.Отметка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОстВариантов.Организация КАК Организация,
	|	ОстВариантов.Поставщик КАК Поставщик,
	|	ОстВариантов.Склад КАК Склад,
	|	ОстВариантов.ВариантКомплектации КАК ВариантКомплектации,
	|	ОстВариантов.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ остатки
	|ИЗ
	|	РегистрНакопления.гф_ВариантыКомплектацииКЗаказуПоставщикам.Остатки(
	|			,
	|			Организация В
	|					(ВЫБРАТЬ
	|						т.Организация
	|					ИЗ
	|						ИсходныеДанные КАК т)
	|				И Поставщик В
	|					(ВЫБРАТЬ
	|						т1.Поставщик
	|					ИЗ
	|						ИсходныеДанные КАК т1)
	|				И ВариантКомплектации В
	|					(ВЫБРАТЬ
	|						т2.ВариантКомплектации
	|					ИЗ
	|						ИсходныеДанные КАК т2)
	|				И Склад В
	|					(ВЫБРАТЬ
	|						т3.Склад
	|					ИЗ
	|						ИсходныеДанные КАК т3)) КАК ОстВариантов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаказПоставщику.Ссылка КАК Ссылка,
	|	ЗаказПоставщику.Статус КАК Статус,
	|	ЗаказПоставщику.Контрагент КАК Контрагент,
	|	ЗаказПоставщику.Организация КАК Организация,
	|	ЗаказПоставщику.Склад КАК Склад
	|ПОМЕСТИТЬ ЗаказыПоОстаткам
	|ИЗ
	|	остатки КАК остатки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказПоставщику КАК ЗаказПоставщику
	|		ПО (ЗаказПоставщику.Проведен)
	|			И (ЗаказПоставщику.Организация = остатки.Организация)
	|			И (ЗаказПоставщику.Контрагент = остатки.Поставщик)
	|			И (ЗаказПоставщику.Склад = остатки.Склад)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Заказы.Ссылка КАК Ссылка,
	|	Заказы.Статус КАК Статус,
	|	Заказы.Контрагент КАК Контрагент,
	|	Заказы.Организация КАК Организация,
	|	Заказы.Склад КАК Склад,
	|	ПродукцияВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	ПродукцияВКоробах.КоличествоКоробов КАК КоличествоКоробов
	|ПОМЕСТИТЬ ВариантыВЗаказахПоОстаткам
	|ИЗ
	|	ЗаказыПоОстаткам КАК Заказы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказПоставщику.гф_ПродукцияВКоробах КАК ПродукцияВКоробах
	|		ПО Заказы.Ссылка = ПродукцияВКоробах.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	остатки.Организация КАК Организация,
	|	остатки.Поставщик КАК Поставщик,
	|	остатки.Склад КАК Склад,
	|	остатки.ВариантКомплектации КАК ВариантКомплектации,
	|	остатки.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ ЗаказыКСозданию
	|ИЗ
	|	остатки КАК остатки
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВариантыВЗаказахПоОстаткам КАК ВариантыВЗаказахПоОстаткам
	|		ПО остатки.Организация = ВариантыВЗаказахПоОстаткам.Организация
	|			И остатки.Поставщик = ВариантыВЗаказахПоОстаткам.Контрагент
	|			И остатки.ВариантКомплектации = ВариантыВЗаказахПоОстаткам.ВариантКомплектации
	|ГДЕ
	|	ВариантыВЗаказахПоОстаткам.Ссылка ЕСТЬ NULL
	|	И остатки.КоличествоОстаток > 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1000000
	|	остатки.Организация КАК Организация,
	|	остатки.Поставщик КАК Поставщик,
	|	остатки.Склад КАК Склад,
	|	остатки.ВариантКомплектации КАК ВариантКомплектации,
	|	ВариантыВЗаказахПоОстаткам.Ссылка КАК ЗаказПоставщику,
	|	ВариантыВЗаказахПоОстаткам.Ссылка.Дата КАК ДатаЗаказаПоставщику,
	|	ВариантыВЗаказахПоОстаткам.Статус КАК СтатусЗаказаПоставщику,
	|	ВЫБОР
	|		КОГДА ВариантыВЗаказахПоОстаткам.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовПоставщикам.НеСогласован)
	|			ТОГДА 1
	|		ИНАЧЕ 2
	|	КОНЕЦ КАК ПорядокПоСтатусу,
	|	ЕСТЬNULL(ВариантыВЗаказахПоОстаткам.КоличествоКоробов, 0) КАК КоличествоКоробовЗаказа,
	|	остатки.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ ЗаказыКИзменению
	|ИЗ
	|	остатки КАК остатки
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВариантыВЗаказахПоОстаткам КАК ВариантыВЗаказахПоОстаткам
	|		ПО остатки.Организация = ВариантыВЗаказахПоОстаткам.Организация
	|			И остатки.Поставщик = ВариантыВЗаказахПоОстаткам.Контрагент
	|			И остатки.ВариантКомплектации = ВариантыВЗаказахПоОстаткам.ВариантКомплектации
	|ГДЕ
	|	ВариантыВЗаказахПоОстаткам.Ссылка ЕСТЬ НЕ NULL 
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПорядокПоСтатусу,
	|	ДатаЗаказаПоставщику,
	|	ЗаказПоставщику";
	
	тз = Объект.ЗаказыКлиентов.Выгрузить();
	Запрос.УстановитьПараметр("тз", тз);
	ПакетРезультатов = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	
	Возврат ПакетРезультатов;
	
КонецФункции

&НаСервере
Процедура СформироватьЗаказыПоставщикуНаСервере()
	ПакетРезультатов = ВыбратьОстаткиДляВариантовДляОбработки();
	РезультатОстаткиКСозданию = ПакетРезультатов[5];
	РезультатОстаткиКИзменению = ПакетРезультатов[6];
	
	Если РезультатОстаткиКСозданию.Пустой() И РезультатОстаткиКИзменению.Пустой() Тогда
		Возврат;	
	КонецЕсли;
	
	// 1. Создание новых заказов поставщику
	Если Не РезультатОстаткиКСозданию.Пустой() Тогда
		СоздатьЗаказыПоставщику(РезультатОстаткиКСозданию);
	КонецЕсли;
	
	// 2. Изменение существующих заказов поставщику если статус заказа "НеСогласован"
	// или создание новых заказов поставщику, если любой другой статус
		Если Не РезультатОстаткиКИзменению.Пустой() Тогда
		ИзменитьИлиСоздатьЗаказыПоставщику(РезультатОстаткиКИзменению);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ИзменитьИлиСоздатьЗаказыПоставщику(РезультатЗапроса)
	
	ТаблицаДляИзмененияПолная = РезультатЗапроса.Выгрузить();
	ТаблицаСвернутоПоРеквизитамЗаказа = ТаблицаДляИзмененияПолная.Скопировать();
	СтрокаСвертки = "Организация, Поставщик, Склад";
	ТаблицаСвернутоПоРеквизитамЗаказа.Свернуть(СтрокаСвертки);
	СтруктураРеквизитов = Новый Структура(СтрокаСвертки);
	Для каждого стрТз Из ТаблицаСвернутоПоРеквизитамЗаказа Цикл
		ЗаполнитьЗначенияСвойств(СтруктураРеквизитов, стрТз);
		мСтрок = ТаблицаДляИзмененияПолная.НайтиСтроки(СтруктураРеквизитов);
		ТаблицаПоПоствщикуСкладу = ТаблицаДляИзмененияПолная.Скопировать();
		
		// 1. Изменение заказов
		РезультатЗапросаДанныхДляИзмененияЗаказов =
		ПолучитьРезультатыДляИзмененияЗаказовПоставщику(ТаблицаПоПоствщикуСкладу);
		ВыборкаИтогиЗаказИзменение = 
		РезультатЗапросаДанныхДляИзмененияЗаказов.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаИтогиЗаказИзменение.Следующий() Цикл
			обЗаказ = ВыборкаИтогиЗаказИзменение["ЗаказПоставщику"].ПолучитьОбъект();
			Если обЗаказ <> Неопределено Тогда
				ПродукцияВКоробах = обЗаказ["гф_ПродукцияВКоробах"].Выгрузить();
				ПродукцияВКоробах.Колонки.Добавить("КоличествоКоробов1",
				Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15, 2, ДопустимыйЗнак.Любой)));
				Для каждого стрТЗ Из ПродукцияВКоробах Цикл
					стрТЗ["КоличествоКоробов1"] = стрТЗ["КоличествоКоробов"];
				КонецЦикла;
				ВыборкаИтогиВариант = ВыборкаИтогиЗаказИзменение.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаИтогиВариант.Следующий() Цикл
					ВыборкаДетали = ВыборкаИтогиВариант.Выбрать();
					Пока ВыборкаДетали.Следующий() Цикл
						нс = ПродукцияВКоробах.Добавить();
						нс["ВариантКомплектации"] = ВыборкаДетали["ВариантКомплектации"];
						нс["КоличествоКоробов1"] = ВыборкаДетали["КоличествоОстаток"];
					КонецЦикла;
				КонецЦикла;
				
				ПродукцияВКоробах.Свернуть("ВариантКомплектации", "КоличествоКоробов, КоличествоКоробов1");
				Для каждого стрТЗ Из ПродукцияВКоробах Цикл
					стрТЗ["КоличествоКоробов"] = стрТЗ["КоличествоКоробов1"];
				КонецЦикла;
				ПродукцияВКоробах.Колонки.Удалить("КоличествоКоробов1");
				мУдаляемыхСтрок = Новый Массив; 
				Для каждого стрТЗ Из ПродукцияВКоробах Цикл
					Если стрТЗ["КоличествоКоробов"] <= 0 Тогда
						мУдаляемыхСтрок.Добавить(стрТЗ);
					КонецЕсли;
				КонецЦикла;
				Для каждого Эл Из мУдаляемыхСтрок Цикл
					ПродукцияВКоробах.Удалить(Эл);
				КонецЦикла;
				
				ПродукцияВКоробах.Сортировать("КоличествоКоробов");
				обЗаказ["гф_ПродукцияВКоробах"].Загрузить(ПродукцияВКоробах);
				обЗаказ.гф_ПересчитатьТЧТоварыНаОсновнииКоробов();
				
				Попытка
					обЗаказ.Записать(РежимЗаписиДокумента.Проведение);
					// Записать в протокол документ проведен
				Исключение
					// Записать в протокол ошибка проведения
					Попытка
						обЗаказ.Проведен = Ложь;
						обЗаказ.Записать(РежимЗаписиДокумента.Запись);
						// записать в протокол документ записан
					Исключение
						// Записать в протокол ошибка записи
					КонецПопытки;
				КонецПопытки;
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЦикла;
		
		// 2. Создание новых заказов
		РезультатЗапросаСозданиеЗаказов =
		ПолучитьРезультатыДляСозданияНовыхЗаказовЕслиЗаказЗаблокирован(ТаблицаПоПоствщикуСкладу);
		ВыборкаОрганизация = РезультатЗапросаСозданиеЗаказов.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаОрганизация.Следующий() Цикл
			ВыборкаПоставщик = ВыборкаОрганизация.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаПоставщик.Следующий() Цикл
				
				ВыборкаСклад = ВыборкаПоставщик.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаСклад.Следующий() Цикл
					
					СтруктураПоиска = Новый Структура("Организация, Поставщик, Склад, Отметка");
					СтруктураПоиска["Отметка"] = Истина;
					ЗаполнитьЗначенияСвойств(СтруктураПоиска, ВыборкаСклад);
					мСтрок = Объект.ЗаказыКлиентов.НайтиСтроки(СтруктураПоиска);
					
					Если мСтрок.Количество()  >= 0 Тогда
						
						Основание = мСтрок[0].ЗаказКлиента;
						ДанныеЗаполнения = СтруктураДокументаОснованияНаСервере(Основание, Истина);
						
						ЗаказПоставщику = Документы.ЗаказПоставщику.СоздатьДокумент();
						ЗаказПоставщику.Дата = НачалоДня(ТекущаяДатаСеанса());
						ЗаказПоставщику.Партнер = СтруктураПоиска["Поставщик"].Партнер;
						ЗаказПоставщику.Заполнить(ДанныеЗаполнения);
						
						ЗаказПоставщику.ДокументОснование = "";
						
						ЗаказПоставщику.ЦенаВключаетНДС = Истина;
						ЗаказПоставщику.Товары.Очистить();
						ВыборкаДетали = ВыборкаСклад.Выбрать();
						Пока ВыборкаДетали.Следующий() Цикл
							нс = ЗаказПоставщику.гф_ПродукцияВКоробах.Добавить();
							нс["ВариантКомплектации"] = ВыборкаДетали["ВариантКомплектации"];
							нс["КоличествоКоробов"] = ВыборкаДетали["КоличествоОстаток"];
						КонецЦикла;
						ЗаказПоставщику.гф_ПересчитатьТЧТоварыНаОсновнииКоробов();
						ЗаказПоставщику.Статус = Перечисления.СтатусыЗаказовПоставщикам.НеСогласован;
						Попытка
							ЗаказПоставщику.Записать(РежимЗаписиДокумента.Проведение);
							// Записать в протокол документ проведен
						Исключение
							// Записать в протокол ошибка проведения
							Попытка
								ЗаказПоставщику.Записать(РежимЗаписиДокумента.Запись);
								// записать в протокол документ записан
							Исключение
								// Записать в протокол ошибка записи
							КонецПопытки;
						КонецПопытки;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРезультатыДляСозданияНовыхЗаказовЕслиЗаказЗаблокирован(тз)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("тз", тз);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	т.Организация КАК Организация,
	|	т.Поставщик КАК Поставщик,
	|	т.Склад КАК Склад,
	|	т.ВариантКомплектации КАК ВариантКомплектации,
	|	т.ЗаказПоставщику КАК ЗаказПоставщику,
	|	т.ДатаЗаказаПоставщику КАК ДатаЗаказаПоставщику,
	|	т.СтатусЗаказаПоставщику КАК СтатусЗаказаПоставщику,
	|	т.ПорядокПоСтатусу КАК ПорядокПоСтатусу,
	|	т.КоличествоКоробовЗаказа КАК КоличествоКоробовЗаказа,
	|	т.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ Данные
	|ИЗ
	|	&тз КАК т
	|ГДЕ
	|	НЕ т.СтатусЗаказаПоставщику = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовПоставщикам.НеСогласован)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.Организация КАК Организация,
	|	Данные.Поставщик КАК Поставщик,
	|	Данные.Склад КАК Склад,
	|	Данные.ВариантКомплектации КАК ВариантКомплектации,
	|	МИНИМУМ(Данные.КоличествоОстаток) КАК КоличествоОстаток
	|ИЗ
	|	Данные КАК Данные
	|
	|СГРУППИРОВАТЬ ПО
	|	Данные.Организация,
	|	Данные.Поставщик,
	|	Данные.Склад,
	|	Данные.ВариантКомплектации
	|
	|ИМЕЮЩИЕ
	|	МИНИМУМ(Данные.КоличествоОстаток) > 0
	|ИТОГИ ПО
	|	Организация,
	|	Поставщик,
	|	Склад";
	
	Результат = Запрос.Выполнить();
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПолучитьРезультатыДляИзмененияЗаказовПоставщику(тз)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("тз", тз);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	т.Организация КАК Организация,
	|	т.Поставщик КАК Поставщик,
	|	т.Склад КАК Склад,
	|	т.ВариантКомплектации КАК ВариантКомплектации,
	|	т.ЗаказПоставщику КАК ЗаказПоставщику,
	|	т.ДатаЗаказаПоставщику КАК ДатаЗаказаПоставщику,
	|	т.СтатусЗаказаПоставщику КАК СтатусЗаказаПоставщику,
	|	т.ПорядокПоСтатусу КАК ПорядокПоСтатусу,
	|	т.КоличествоКоробовЗаказа КАК КоличествоКоробовЗаказа,
	|	т.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ Данные
	|ИЗ
	|	&тз КАК т
	|ГДЕ
	|	т.СтатусЗаказаПоставщику = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовПоставщикам.НеСогласован)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.Организация КАК Организация,
	|	Данные.Поставщик КАК Поставщик,
	|	Данные.Склад КАК Склад,
	|	Данные.ВариантКомплектации КАК ВариантКомплектации,
	|	МИНИМУМ(Данные.ДатаЗаказаПоставщику) КАК ДатаЗаказаПоставщику
	|ПОМЕСТИТЬ ДанныеСвернутоПоДатеЗаказа
	|ИЗ
	|	Данные КАК Данные
	|
	|СГРУППИРОВАТЬ ПО
	|	Данные.Организация,
	|	Данные.Поставщик,
	|	Данные.Склад,
	|	Данные.ВариантКомплектации
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.Организация КАК Организация,
	|	Данные.Поставщик КАК Поставщик,
	|	Данные.Склад КАК Склад,
	|	Данные.ВариантКомплектации КАК ВариантКомплектации,
	|	Данные.ДатаЗаказаПоставщику КАК ДатаЗаказаПоставщику,
	|	МИНИМУМ(Данные.ЗаказПоставщику) КАК ЗаказПоставщику
	|ПОМЕСТИТЬ ДанныеСвернутоСсылкеЗаказа
	|ИЗ
	|	Данные КАК Данные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ДанныеСвернутоПоДатеЗаказа КАК ДанныеСвернутоПоДатеЗаказа
	|		ПО Данные.Организация = ДанныеСвернутоПоДатеЗаказа.Организация
	|			И Данные.Поставщик = ДанныеСвернутоПоДатеЗаказа.Поставщик
	|			И Данные.Склад = ДанныеСвернутоПоДатеЗаказа.Склад
	|			И Данные.ВариантКомплектации = ДанныеСвернутоПоДатеЗаказа.ВариантКомплектации
	|			И Данные.ДатаЗаказаПоставщику = ДанныеСвернутоПоДатеЗаказа.ДатаЗаказаПоставщику
	|
	|СГРУППИРОВАТЬ ПО
	|	Данные.Организация,
	|	Данные.Поставщик,
	|	Данные.Склад,
	|	Данные.ВариантКомплектации,
	|	Данные.ДатаЗаказаПоставщику
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ 
	|	Данные.ЗаказПоставщику КАК ЗаказПоставщику,
	|	Данные.ВариантКомплектации КАК ВариантКомплектации,
	|	Данные.КоличествоКоробовЗаказа КАК КоличествоКоробовЗаказа,
	|	Данные.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	Данные КАК Данные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ДанныеСвернутоСсылкеЗаказа КАК ДанныеСвернутоСсылкеЗаказа
	|		ПО (Данные.ЗаказПоставщику = ДанныеСвернутоСсылкеЗаказа.ЗаказПоставщику)
	|			И (Данные.ВариантКомплектации = ДанныеСвернутоСсылкеЗаказа.ВариантКомплектации)
	|			И (Данные.ДатаЗаказаПоставщику = ДанныеСвернутоСсылкеЗаказа.ДатаЗаказаПоставщику)
	|ИТОГИ
	|	Сумма(КоличествоКоробовЗаказа),
	|	Максимум(КоличествоОстаток)
	|ПО
	|	ЗаказПоставщику,
	|	ВариантКомплектации";
	Результат = Запрос.Выполнить();
	Возврат Результат;
	
КонецФункции



&НаСервере
Процедура СоздатьЗаказыПоставщику(РезультатЗапроса)
	ТаблицаДанных = Объект.ЗаказыКлиентов.Выгрузить();
	ПолнаяТаблицаКСозданию = РезультатЗапроса.Выгрузить();
	
	ТаблицаДанныхЗаказов = ПолнаяТаблицаКСозданию.Скопировать();
	ТаблицаДанныхЗаказов.Свернуть("Организация, Поставщик, Склад");
	
	ДатаЗаказа = НачалоДня(ТекущаяДатаСеанса());
	Для каждого стрТз Из ТаблицаДанныхЗаказов Цикл
		СтруктураПоиска = Новый Структура("Организация, Поставщик, Склад, Отметка");
		СтруктураПоиска["Отметка"] = Истина;
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, стрТз);
		мСтрок = ТаблицаДанных.НайтиСтроки(СтруктураПоиска);
		ТаблицаПоОтбору = ТаблицаДанных.Скопировать(мСтрок);
		мЗаказов = ТаблицаПоОтбору.ВыгрузитьКолонку("ЗаказКлиента");
		мУникальныхЗаказов = Новый Массив;
		ОбщегоНазначенияКлиентСервер.ДополнитьМассив(мУникальныхЗаказов, мЗаказов, Истина);
		
		Основание = ТаблицаПоОтбору[0].ЗаказКлиента;
		
		ДанныеЗаполнения = СтруктураДокументаОснованияНаСервере(Основание, Истина);
		
		ЗаказПоставщику = Документы.ЗаказПоставщику.СоздатьДокумент();
		ЗаказПоставщику.Дата = ДатаЗаказа;
		ЗаказПоставщику.Партнер = СтруктураПоиска["Поставщик"].Партнер;
		ЗаказПоставщику.Заполнить(ДанныеЗаполнения);
		
		// vvv Галфинд \ Sakovich 07.04.2023
		//Если мУникальныхЗаказов.ВГраница() = 0 Тогда
		//	ЗаказПоставщику.ДокументОснование = мУникальныхЗаказов[0];
		//Иначе
		//	ЗаказПоставщику.ДокументОснование = "";
		//КонецЕсли;
		ЗаказПоставщику.ДокументОснование = "";
		// ^^^ Галфинд \ Sakovich 07.04.2023 
		
		// vvv Галфинд \ Sakovich 19.01.2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8128bcee7bda45d711ed81d995d24d7d
		ЗаказПоставщику.ЦенаВключаетНДС = Истина;
		// ^^^ Галфинд \ Sakovich 19.01.2023 
		
		ЗаказПоставщику.Товары.Очистить();
		СтруктураПоиска.Удалить("Отметка");
		мстрВарианты = ПолнаяТаблицаКСозданию.НайтиСтроки(СтруктураПоиска);
		ДанныеПоКоробам = ПолнаяТаблицаКСозданию.Скопировать(мСтрВарианты);
		ДанныеПоКоробам.Свернуть("ВариантКомплектации", "КоличествоОстаток");
		ДанныеПоКоробам.Сортировать("КоличествоОстаток");
		Для каждого стрТз Из ДанныеПоКоробам Цикл
			нс = ЗаказПоставщику.гф_ПродукцияВКоробах.Добавить();
			нс["ВариантКомплектации"] = стрТз["ВариантКомплектации"];
			нс["КоличествоКоробов"] = стрТз["КоличествоОстаток"];
		КонецЦикла;
		ЗаказПоставщику.гф_ПересчитатьТЧТоварыНаОсновнииКоробов();
		// vvv Галфинд \ Sakovich 05.04.2023
		ЗаказПоставщику.Статус = Перечисления.СтатусыЗаказовПоставщикам.НеСогласован;
		// ^^^ Галфинд \ Sakovich 05.04.2023 
		
		////$$$===========================vvv ОТЛАДКА vvv======================07.02.2023 20:27:15=============| SBB
		//Для каждого стрТч Из ЗаказПоставщику.Товары Цикл
		//	стрТч["Цена"] = 100;
		//	стрТч["Сумма"] = стрТч["Цена"] * стрТч["КоличествоУпаковок"];
		//	стрТч["СуммаНДС"] = стрТч["Сумма"] * 20 / 100;
		//	стрТч["СуммаСНДС"] = стрТч["Сумма"] + стрТч["СуммаНДС"]
		//КонецЦикла;
		//ЗаказПоставщику.гф_ПересчитатьСуммыТчТоваровВКоробахПоТчТовары();
		////===========================^^^ КОНЕЦ ОТЛАДКИ ^^^===================07.02.2023 20:27:15=============| SBB
		
		Попытка
			ЗаказПоставщику.Записать(РежимЗаписиДокумента.Проведение);
			// Записать в протокол документ проведен
		Исключение
			// Записать в протокол ошибка проведения
			Попытка
				ЗаказПоставщику.Записать(РежимЗаписиДокумента.Запись);
				// записать в протокол документ записан
			Исключение
				// Записать в протокол ошибка записи
			КонецПопытки;
		КонецПопытки;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Функция СтруктураДокументаОснованияНаСервере(ДокументОснование, ИспользованиеСкладов)
	ЕстьРеквизитШапкиСклад = ОбщегоНазначения.ЕстьРеквизитОбъекта("Склад", ДокументОснование.Метаданные());
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация", "Организация");
	СтруктураПолей.Вставить("Подразделение", "Подразделение");
	СтруктураПолей.Вставить("ДокументОснование", "Ссылка");
	СтруктураПолей.Вставить("НаправлениеДеятельности");
	
	Если ЕстьРеквизитШапкиСклад Тогда
		СтруктураПолей.Вставить("Склад", "Склад");
		СтруктураПолей.Вставить("Сделка", "Сделка");
		СтруктураПолей.Вставить("СкладЭтоГруппа", "Склад.ЭтоГруппа");
		СтруктураПолей.Вставить("Приоритет", "Приоритет");
	КонецЕсли;
	
	РеквизитыЗаполнения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДокументОснование, СтруктураПолей);
	СтрокаПолей = "Организация, ДокументОснование, Подразделение, Склад, Сделка, Приоритет, НаправлениеДеятельности";
		
	РеквизитыОснования = Новый Структура(СтрокаПолей);
	ЗаполнитьЗначенияСвойств(РеквизитыОснования, РеквизитыЗаполнения, СтрокаПолей);

	Возврат РеквизитыОснования;

КонецФункции 

&НаКлиенте
Процедура СформироватьЗаказыПоставщику(Команда)
	СформироватьЗаказыПоставщикуНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	// Вставить содержимое обработчика.
КонецПроцедуры
