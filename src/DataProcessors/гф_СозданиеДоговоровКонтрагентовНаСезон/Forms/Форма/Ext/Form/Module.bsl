﻿#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	#Область СКД_Отбор
	
	СКД_Отбор = РеквизитФормыВЗначение("Объект").ПолучитьМакет("СКД_Отбор"); 
	
	АдресВоВремХранилище = ПоместитьВоВременноеХранилище(СКД_Отбор, УникальныйИдентификатор);
	
	ИсточникНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресВоВремХранилище);
	КомпоновщикНастроек.Инициализировать(ИсточникНастроек);
	КомпоновщикНастроек.ЗагрузитьНастройки(СКД_Отбор.НастройкиПоУмолчанию);
	
	#КонецОбласти

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоздатьДоговора(Команда)
	ОписаниеОповещения = Новый ОписаниеОповещения("ВопросСозданиеДоговора", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Создать договоры?", РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоговорОсновным(Команда)
	ОписаниеОповещения = Новый ОписаниеОповещения("ВопросУстановитьДоговорОсновным", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Установить договоры основными?", РежимДиалогаВопрос.ДаНет,
	, КодВозвратаДиалога.Да);
КонецПроцедуры

&НаКлиенте
Процедура ВопросСозданиеДоговора(Ответ, ДопПараметры) Экспорт
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ВыполнитьСозданиеДоговора();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьСозданиеДоговора()
	
	Если Объект.Сезон.Пустая() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнен сезон!");
		Возврат;
	КонецЕсли;
	
	Состояние("Запрос по контрагентам...");
	
	МассивКонтрагентов = ПолучениеКонтрагентовЧерезПостроитель();
	
	ПараметрыСезона = НайтиПараметрыПоСезону();
	
	Для каждого ОтобранныйКонтрагент Из МассивКонтрагентов Цикл
		Состояние(ОтобранныйКонтрагент);
		
		ОбработкаПрерыванияПользователя();
		
		ВыполнитьСозданиеДоговораНаСервере(ПараметрыСезона, ОтобранныйКонтрагент);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьСозданиеДоговораНаСервере(ПараметрыСезона, Контрагент)
	
	руб = Справочники.Валюты.НайтиПоКоду("643").Ссылка;
	
	нашли_договора = НайтиДоговорПоСезону(Контрагент); // Изменено  Галфинд \ Sakovich 13.09.2023 11:51:20   old:<нашли_договор>
	
	ДоговораПредыдущегоСезона = НайтиДоговорПредыдущегоСезона(Контрагент); // Изменено  Галфинд \ Sakovich 13.09.2023 11:51:51   old:<ДоговорПредыдущегоСезона>
	
	
	// vvv Галфинд \ Sakovich 13.09.2023
	//Если нашли_договор = Неопределено Тогда	
	Если нашли_договора.Количество() = 0 И ДоговораПредыдущегоСезона.Количество() = 0 Тогда
	// ^^^ Галфинд \ Sakovich 13.09.2023
		спр = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
		спр.ОбменДанными.Загрузка = Истина;
		спр.Контрагент = Контрагент;
		спр.Партнер = Контрагент.Партнер;
		спр.Организация = Объект.Организация;
		спр.Наименование = ПараметрыСезона.Наименование;
		Партнер = Справочники.Партнеры.НайтиПоНаименованию(Контрагент);
		спр.Код = СокрЛП(Партнер.Код) + "_" + сокрЛП(ПараметрыСезона.гф_Номер) + прав(ПараметрыСезона.гф_Год, 2);
		спр.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоДоговорамКонтрагентов;
		спр.ВалютаВзаиморасчетов = руб;
		спр.ТипДоговора = Перечисления.ТипыДоговоров.СПокупателем;
		спр.ОграничиватьСуммуЗадолженности = Истина;
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// спрятано ниже в зависимости от наличия ДоговораПредыдущегоСезона
		// Галфинд Домнышева 2022/08/23
		//спр.Дата = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
		//спр.ДатаНачалаДействия = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
		// } #wortmann
		спр.ДатаОкончанияДействия = ПараметрыСезона.гф_ДатаОкончанияОтгрузкиЗаказов;
		спр.гф_ДатаНачалаИспользованияДоговораПриЗагрузкеДанных = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
		спр.гф_ДатаОкончанияИспользованияДоговораПриЗагрузкеДанных = ПараметрыСезона.гф_ДатаОкончанияОтгрузкиЗаказов;
		спр.гф_Сезон = ПараметрыСезона.Ссылка;
		Если Контрагент.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицоНеРезидент Тогда
			спр.НалогообложениеНДСОпределяетсяВДокументе = Ложь;
			спр.НалогообложениеНДС = Перечисления.ТипыНалогообложенияНДС.ПродажаНаЭкспорт;
		Иначе
			спр.НалогообложениеНДСОпределяетсяВДокументе =  Истина;
		КонецЕсли;
		спр.Статус = Перечисления.СтатусыДоговоровКонтрагентов.Действует;				
		
		спр.Номер = Объект.Организация.Префикс + "-" + Партнер.Код;
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// Заполнение значений реквизитов Дата и ДатаНачалаДействия в зависимости от наличия ДоговораПредыдущегоСезона
		// Галфинд Домнышева 2022/08/23
		спр.Дата = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
		спр.ДатаНачалаДействия = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
		// } #wortmann	   
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed2e85e1c4f75a
		// Заполнение реквизита Хоз.Операции для отображения в списке подбора договоров из формы Док.ЗаказКлиента
		// Заполнение других реквизитов не указанных в задаче, но заполняемых при ручном создании договоров.
		// Галфинд Домнышева 2022/09/07	
		спр.ХозяйственнаяОперация = Перечисления.ХозяйственныеОперации.РеализацияКлиенту;
		спр.НаименованиеДляПечати = спр.Наименование;
		спр.Согласован = Истина;
		Отказ = Ложь;
		ВзаиморасчетыСервер.ПередЗаписью(спр, Отказ);
		// } #wortmann
		спр.Записать();
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Создан договор " + спр.Ссылка); 
	// vvv Галфинд \ Sakovich 13.09.2023
	ИначеЕсли  нашли_договора.Количество() = 0 И ДоговораПредыдущегоСезона.Количество() > 0 Тогда
		Для каждого ПредыдущийДоговор Из ДоговораПредыдущегоСезона Цикл
			спр = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
			спр.ОбменДанными.Загрузка = Истина;
			спр.Контрагент = Контрагент;
			спр.Партнер = Контрагент.Партнер;
			спр.Организация = Объект.Организация;
			спр.Наименование = ПараметрыСезона.Наименование;
			Партнер = Справочники.Партнеры.НайтиПоНаименованию(Контрагент);
			спр.Код = СокрЛП(Партнер.Код) + "_" + сокрЛП(ПараметрыСезона.гф_Номер) + прав(ПараметрыСезона.гф_Год, 2);
			спр.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоДоговорамКонтрагентов;
			спр.ВалютаВзаиморасчетов = руб;
			спр.ТипДоговора = Перечисления.ТипыДоговоров.СПокупателем;
			спр.ОграничиватьСуммуЗадолженности = Истина;
			спр.ДатаОкончанияДействия = ПараметрыСезона.гф_ДатаОкончанияОтгрузкиЗаказов;
			спр.гф_ДатаНачалаИспользованияДоговораПриЗагрузкеДанных = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
			спр.гф_ДатаОкончанияИспользованияДоговораПриЗагрузкеДанных = ПараметрыСезона.гф_ДатаОкончанияОтгрузкиЗаказов;
			спр.гф_Сезон = ПараметрыСезона.Ссылка;
			Если Контрагент.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицоНеРезидент Тогда
				спр.НалогообложениеНДСОпределяетсяВДокументе = Ложь;
				спр.НалогообложениеНДС = Перечисления.ТипыНалогообложенияНДС.ПродажаНаЭкспорт;
			Иначе
				спр.НалогообложениеНДСОпределяетсяВДокументе =  Истина;
			КонецЕсли;
			спр.Статус = Перечисления.СтатусыДоговоровКонтрагентов.Действует;				
			спр.Номер = ПредыдущийДоговор.Номер;
			спр.Дата = ПредыдущийДоговор.Дата;
			спр.ДатаНачалаДействия = ПредыдущийДоговор.ДатаНачалаДействия;
			спр.ХозяйственнаяОперация = Перечисления.ХозяйственныеОперации.РеализацияКлиенту;
			спр.НаименованиеДляПечати = спр.Наименование;
			спр.Согласован = Истина;
			Отказ = Ложь;
			ВзаиморасчетыСервер.ПередЗаписью(спр, Отказ);
			спр.Записать();
			ПерезаписатьСвойства(ПредыдущийДоговор, спр); 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Создан договор " + спр.Ссылка); 
		КонецЦикла;
		// ^^^ Галфинд \ Sakovich 13.09.2023
	Иначе
		Для каждого ДоговорЭтогоСезона  Из нашли_договора Цикл
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Для контрагента " + Контрагент + " по сезону " + Объект.Сезон + " уже существует договор: " + ДоговорЭтогоСезона);
		КонецЦикла;
		
		Если Объект.ПерезаполнятьСвойства
			И ДоговораПредыдущегоСезона.Количество() = 1 
			И нашли_договора.Количество() = 1 Тогда
			ПерезаписатьСвойства(ДоговораПредыдущегоСезона[0], нашли_договора[0].ПолучитьОбъект());
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросУстановитьДоговорОсновным(Ответ, ДопПараметры) Экспорт
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ВыполнитьУстановитьДоговорОсновным();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ВыполнитьУстановитьДоговорОсновным()
	
	Если Объект.Сезон.Пустая() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнен сезон!");
		Возврат;
	КонецЕсли;
	
	МассивКонтрагентов = ПолучениеКонтрагентовЧерезПостроитель();
			
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
		|	ДоговорыКонтрагентов.Контрагент КАК Контрагент
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Контрагент В(&МассивКонтрагентов)
		|	И ДоговорыКонтрагентов.гф_Сезон = &Сезон
		|	И ДоговорыКонтрагентов.Организация = &Организация
		|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
		|";
	
	Запрос.УстановитьПараметр("МассивКонтрагентов", МассивКонтрагентов);
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		спр = выборка.Контрагент.ПолучитьОбъект();
				
		НайденнаяСтрока = спр["гф_ОсновнойДоговорКонтрагента"].Найти(Объект.Организация, "Организация");  
		
		Если НайденнаяСтрока = Неопределено Тогда
			
			Таблица = спр.гф_ОсновнойДоговорКонтрагента.Добавить();
			Таблица.Организация = Объект.Организация;
			Таблица.ОсновнойДоговор = Выборка.Ссылка;			
		Иначе
			НайденнаяСтрока.ОсновнойДоговор = Выборка.Ссылка;
		КонецЕсли;
		
		спр.ОбменДанными.Загрузка = Истина;
		спр.Записать();	
		
	КонецЦикла;
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучениеКонтрагентовЧерезПостроитель()
	
	СКД_Отбор = РеквизитФормыВЗначение("Объект").ПолучитьМакет("СКД_Отбор"); 
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СКД_Отбор, КомпоновщикНастроек.ПолучитьНастройки(), , ,
	Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	
	ТаблицаКонтрагентов = ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	МассивКонтрагентов = ТаблицаКонтрагентов.ВыгрузитьКолонку("Контрагент");
	
	Возврат МассивКонтрагентов;

КонецФункции

&НаСервере
Функция ПроверкаДоговоровКонтрагента(Контрагент)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.Контрагент = &Контрагент";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда	
		Возврат Ложь;
	Иначе		
		Возврат Истина;
	КонецЕсли;
	
КонецФункции 

&НаСервере
Функция НайтиПараметрыПоСезону()
	
	СтруктураДанных = Новый Структура;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КоллекцииНоменклатуры.Наименование КАК Наименование,
		|	КоллекцииНоменклатуры.гф_Номер КАК гф_Номер,
		|	КоллекцииНоменклатуры.гф_Год КАК гф_Год,
		|	КоллекцииНоменклатуры.гф_ДатаНачалаФормированияЗаказов КАК гф_ДатаНачалаФормированияЗаказов,
		|	КоллекцииНоменклатуры.гф_ДатаОкончанияОтгрузкиЗаказов КАК гф_ДатаОкончанияОтгрузкиЗаказов,
		|	КоллекцииНоменклатуры.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.КоллекцииНоменклатуры КАК КоллекцииНоменклатуры
		|ГДЕ
		|	КоллекцииНоменклатуры.Ссылка = &Сезон";
	
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
			СтруктураДанных.Вставить(Колонка.Имя, Выборка[Колонка.Имя]);
		КонецЦикла;	
	КонецЦикла;
	
	Возврат СтруктураДанных;
	
КонецФункции 

&НаСервере
Функция НайтиДоговорПоСезону(Контрагент)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Контрагент = &Контрагент
		|	И ДоговорыКонтрагентов.Организация = &Организация
		|	И ДоговорыКонтрагентов.гф_Сезон = &Сезон
		|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	
	РезультатЗапроса = Запрос.Выполнить();
	// vvv Галфинд \ Sakovich 13.09.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee3a83a4957c29
	//Выборка = РезультатЗапроса.Выбрать();
	//
	//Если Выборка.Следующий() Тогда
	//	Возврат Выборка.Ссылка;
	//Иначе
	//	Возврат Неопределено;
	//КонецЕсли;
	МассивДоговоров = Новый Массив;
	Если РезультатЗапроса.Пустой() Тогда
		Возврат МассивДоговоров;
	КонецЕсли;
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		МассивДоговоров.Добавить(Выборка.Ссылка);
	КонецЦикла;
	Возврат МассивДоговоров;
	// ^^^ Галфинд \ Sakovich 13.09.2023
			
КонецФункции // НайтиДоговорПоСезону()

&НаСервере
Функция НайтиДоговорПредыдущегоСезона(Контрагент)
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КоллекцииНоменклатуры.гф_Номер КАК Номер,
		|	КоллекцииНоменклатуры.гф_Год КАК Год
		|ИЗ
		|	Справочник.КоллекцииНоменклатуры КАК КоллекцииНоменклатуры
		|ГДЕ
		|	КоллекцииНоменклатуры.Ссылка = &Сезон";
	
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Если НЕ РезультатЗапроса.Пустой() Тогда	
		Если Выборка.Номер = 0 И Выборка.Год = 0 Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		Если Выборка.Номер = 0 Тогда
			Номер = 9;
			// #wortmann {
			// Сезон подбирается между двумя годами (прошлым и текущим)
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed22b61628d876
			// Галфинд_Домнышева 2022/08/25	
			//Год = Выборка.Год - 1; 
			Год1 = Выборка.Год - 1;
			Год2 = Выборка.Год;
			// } #wortmann
		Иначе
			Номер = Выборка.Номер - 1;
			// #wortmann {
			// Сезон подбирается между двумя годами (прошлым и текущим)
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed22b61628d876
			// Галфинд_Домнышева 2022/08/25	
			//Год = Выборка.Год;; 
			Год1 = Выборка.Год - 1;
			Год2 = Выборка.Год;
			// } #wortmann	
		КонецЕсли; 
		
	КонецЕсли; 	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Контрагент = &Контрагент
		|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
		|	И ДоговорыКонтрагентов.Организация = &Организация
		|	И ДоговорыКонтрагентов.гф_Сезон.гф_Номер = &Номер
		// #wortmann {
		// Сезон подбирается между двумя годами (прошлым и текущим).
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed22b61628d876
		// Галфинд_Домнышева 2022/08/25	
		//|	И ДоговорыКонтрагентов.гф_Сезон.гф_Год = &Год";	
		|	И ДоговорыКонтрагентов.гф_Сезон.гф_Год Между &Год1 И &Год2";
		// } #wortmann
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("Номер", Номер);
	// #wortmann {
	// Устанавливаем параметры для двух годов между которыми производим поиск. 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed22b61628d876
	// Галфинд_Домнышева 2022/08/25	
	//Запрос.УстановитьПараметр("Год", Год);
    Запрос.УстановитьПараметр("Год1", Год1);
	Запрос.УстановитьПараметр("Год2", Год2);
	// } #wortmann
		
	РезультатЗапроса = Запрос.Выполнить();
	
	// vvv Галфинд \ Sakovich 13.09.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee3a83a4957c29
	//Выборка = РезультатЗапроса.Выбрать();
	//Выборка.Следующий();
	//
	//Если НЕ РезультатЗапроса.Пустой() Тогда
	//	Возврат выборка.Ссылка;
	//Иначе
	//	Возврат Неопределено;
	//КонецЕсли;
	
	МассивДоговоров = Новый Массив;
	Если РезультатЗапроса.Пустой() Тогда
		Возврат МассивДоговоров;
	КонецЕсли;
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		МассивДоговоров.Добавить(Выборка.Ссылка);
	КонецЦикла;
	Возврат МассивДоговоров;
	// vvv Галфинд \ Sakovich 13.09.2023
		
КонецФункции // ПредыдущийДоговор()

&НаСервере
Функция ПроверкаБессрочныхПроцентов(Номенклатура)
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ПроцентыПредоплаты.Номеклатура КАК Номеклатура
		|ИЗ
		|	РегистрСведений.гф_ПроцентыПредоплаты КАК гф_ПроцентыПредоплаты
		|ГДЕ
		|	гф_ПроцентыПредоплаты.Бессрочный = ИСТИНА
		|	И гф_ПроцентыПредоплаты.Номеклатура = &Номенклатура";
	
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Возврат Истина;
	КонецЕсли;	
	
КонецФункции  

&НаСервере
Процедура ПерезаписатьСвойства(ДоговорПредыдущегоСезона, ИзменяемыйДоговор)
	
	ОтгрузкаКодовМаркировки = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию(
	"Отгрузка кодов маркировки парами "); 
	ОтгрузкаКодовМаркировкиЗначение = ДоговорПредыдущегоСезона.ДополнительныеРеквизиты.Найти(ОтгрузкаКодовМаркировки);
	
	ПервичныеДокументы = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию(
	"Первичные документы в коробах"); 
	ПервичныеДокументыЗначение = ДоговорПредыдущегоСезона.ДополнительныеРеквизиты.Найти(ПервичныеДокументы); 
	
	Если ОтгрузкаКодовМаркировкиЗначение <> Неопределено  Тогда
		НовыйРеквизит1 = ИзменяемыйДоговор.ДополнительныеРеквизиты.Добавить();
		НовыйРеквизит1.Свойство = ОтгрузкаКодовМаркировки;
		НовыйРеквизит1.ТекстоваяСтрока = "Отгрузка кодов маркировки парами ";
		НовыйРеквизит1.Значение = ОтгрузкаКодовМаркировкиЗначение.Значение;            
	КонецЕсли;
	
	Если ПервичныеДокументыЗначение <> Неопределено  Тогда
		НовыйРеквизит2 = ИзменяемыйДоговор.ДополнительныеРеквизиты.Добавить();
		НовыйРеквизит2.Свойство = ПервичныеДокументы;
		НовыйРеквизит2.ТекстоваяСтрока = "Первичные документы в коробах";
		НовыйРеквизит2.Значение = ПервичныеДокументыЗначение.Значение; 
	КонецЕсли; 
	
	СтраховойДепозит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Страховой депозит"); 
	СтраховойДепозитЗначение = ДоговорПредыдущегоСезона.ДополнительныеРеквизиты.Найти(СтраховойДепозит); 
	
	Предоплата = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Предоплата"); 
	ПредоплатаЗначение = ДоговорПредыдущегоСезона.ДополнительныеРеквизиты.Найти(Предоплата);
	
	Если СтраховойДепозитЗначение <> Неопределено И ПроверкаБессрочныхПроцентов(СтраховойДепозитЗначение.Значение) = Истина Тогда
		НовыйРеквизит3 = ИзменяемыйДоговор.ДополнительныеРеквизиты.Добавить();
		НовыйРеквизит3.Свойство = СтраховойДепозит;
		НовыйРеквизит3.ТекстоваяСтрока = "Страховой депозит";
		НовыйРеквизит3.Значение = СтраховойДепозитЗначение.Значение; 
	КонецЕсли;
	
	Если ПредоплатаЗначение <> Неопределено И ПроверкаБессрочныхПроцентов(ПредоплатаЗначение.Значение) = Истина Тогда
		НовыйРеквизит4 = ИзменяемыйДоговор.ДополнительныеРеквизиты.Добавить();
		НовыйРеквизит4.Свойство = Предоплата;
		НовыйРеквизит4.ТекстоваяСтрока = "Предоплата";
		НовыйРеквизит4.Значение = ПредоплатаЗначение.Значение; 
	КонецЕсли;
	
	// vvv Галфинд \ Sakovich 09.08.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee31f4052879e4
	// при создании договоров копировать ТЧ "GLN" из договора предыдущего сезона
	Если ДоговорПредыдущегоСезона["гф_GLN"].Количество() <> 0 Тогда
		тзGLN = ДоговорПредыдущегоСезона["гф_GLN"].Выгрузить();
		ИзменяемыйДоговор["гф_GLN"].Загрузить(тзGLN);
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 09.08.2023
	
	ИзменяемыйДоговор.Записать(); 

КонецПроцедуры

#КонецОбласти
