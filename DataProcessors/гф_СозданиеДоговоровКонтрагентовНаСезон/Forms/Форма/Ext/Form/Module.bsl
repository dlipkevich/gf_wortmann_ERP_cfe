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
	
	нашли_договор = НайтиДоговорПоСезону(Контрагент);
	ДоговорПредыдущегоСезона = НайтиДоговорПредыдущегоСезона(Контрагент);
	Если нашли_договор = Неопределено Тогда
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
		спр.Дата = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
		спр.ДатаНачалаДействия = ПараметрыСезона.гф_ДатаНачалаФормированияЗаказов;
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

		Если ДоговорПредыдущегоСезона <> Неопределено Тогда
			спр.Номер = ДоговорПредыдущегоСезона.Номер; 
		Иначе 	
			спр.Номер = Объект.Организация.Префикс + Партнер.Код;   
		КонецЕсли;
		спр.Записать();
		
		Если ДоговорПредыдущегоСезона <> Неопределено Тогда
			
			ПерезаписатьСвойства(ДоговорПредыдущегоСезона, спр); 
			
		КонецЕсли;
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Создан договор " + спр.Ссылка); 
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Для контрагента " + Контрагент + " договор по сезону " + Объект.Сезон + " существует!");		
		
		Если Объект.ПерезаполнятьСвойства И ДоговорПредыдущегоСезона <> Неопределено  Тогда
			ПерезаписатьСвойства(ДоговорПредыдущегоСезона, нашли_договор.ПолучитьОбъект());
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
		|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
		|	И НЕ ДоговорыКонтрагентов.Контрагент.гф_ОсновнойДоговорКонтрагента = ДоговорыКонтрагентов.Ссылка";
	
	Запрос.УстановитьПараметр("МассивКонтрагентов", МассивКонтрагентов);
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
			
		спр = выборка.Контрагент.ПолучитьОбъект();
		спр.гф_ОсновнойДоговорКонтрагента = выборка.Ссылка;
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
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
		
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
			Год = Выборка.Год - 1;
		Иначе
			Номер = Выборка.Номер - 1;
			Год = Выборка.Год;
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
		|	И ДоговорыКонтрагентов.гф_Сезон.гф_Год = &Год";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("Номер", Номер);
	Запрос.УстановитьПараметр("Год", Год);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Возврат выборка.Ссылка;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
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
	"Первичные документы в парах коробах"); 
	ПервичныеДокументыЗначение = ДоговорПредыдущегоСезона.ДополнительныеРеквизиты.Найти(ПервичныеДокументы); 
	
	НовыйРеквизит1 = ИзменяемыйДоговор.ДополнительныеРеквизиты.Добавить();
	НовыйРеквизит1.Свойство = ОтгрузкаКодовМаркировки;
	НовыйРеквизит1.ТекстоваяСтрока = "Отгрузка кодов маркировки парами ";
	НовыйРеквизит1.Значение = ОтгрузкаКодовМаркировкиЗначение.Значение;            
	
	НовыйРеквизит2 = ИзменяемыйДоговор.ДополнительныеРеквизиты.Добавить();
	НовыйРеквизит2.Свойство = ПервичныеДокументы;
	НовыйРеквизит2.ТекстоваяСтрока = "Первичные документы в парах коробах";
	НовыйРеквизит2.Значение = ПервичныеДокументыЗначение.Значение; 
	
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
	
	ИзменяемыйДоговор.Записать(); 

КонецПроцедуры

#КонецОбласти
