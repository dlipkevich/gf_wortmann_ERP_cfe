﻿
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка) 
	
	гф_СоздатьНовыеРеквизиты();
	
	// vvv Галфинд \ Sakovich 18.01.2023
	гф_УстановитьОтборСтрокТовары();
	// ^^^ Галфинд \ Sakovich 18.01.2023 
КонецПроцедуры	

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_УстановитьОтборСтрокТовары()
	Если Не Объект.РежимПросмотраПоТоварам Тогда
		Объект.РежимПросмотраПоТоварам = 1;
	КонецЕсли;
	Объект.Товары.Сортировать("ЭтоУпаковочныйЛист Возр");
	ДекорацияФильтрОбработкаНавигационнойСсылкиСервер("СнятьОтбор");
КонецПроцедуры

&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
	
	ОписаниеТиповУпаковочныйЛист	= Новый ОписаниеТипов("ДокументСсылка.УпаковочныйЛист");
	
	ДобавляемыеРеквизиты = Новый Массив;
	
	РеквизитФормы_гф_ИДКороба			= Новый РеквизитФормы("гф_ИДКороба",
	ОписаниеТиповУпаковочныйЛист, , "ID короба", Истина);
	
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ИДКороба);
	
	// #wortmann {
	// #учет Кодов Маркиовки (КМ)
	// Галфинд Sakovich 2022/11/02
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");
	РеквизитФормы_гф_ЗаполнятьШтрихкодыУпаковок = 
	Новый РеквизитФормы("гф_ЗаполнятьШтрихкодыУпаковок", ОписаниеТиповБулево);
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ЗаполнятьШтрихкодыУпаковок);
	// } #wortmann
	
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	ТипПолеФормы = Тип("ПолеФормы");
	
	НовоеПоле = Элементы.Добавить("гф_ИДКороба", ТипПолеФормы,
	Элементы.Товары);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.Товары.гф_IDКороба"; 
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ВопросЗаполнитьШтрихкодыУпаковокЗавершение (Результат, ДополнительныеПараметры) Экспорт
	Команда = ДополнительныеПараметры["Команда"];
	гф_ЗаполнятьШтрихкодыУпаковок = Результат = КодВозвратаДиалога.Да;
	ЗаполнитьШтрихкодыУпаковок();
    // #wortmann {
	// ++ Галфинд_Домнышева_КР_20_04_2023
	// Перенесла код в проц. ВыполнениеКомандыПроведения для унификации
	ВыполнениеКомандыПроведения(Команда);
	// } #wortmann

КонецПроцедуры

&НаКлиенте
Функция ОпределитьНеобходимостьЗаполненияШтрихкодовУпаковок()

	НужноЗаполнятьШтрихкодыУпаковок = 
	(Объект.Статус = ПредопределенноеЗначение("Перечисление.СтатусыПриходныхОрдеров.Принят")
	И (ТипЗнч(Объект.Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров")
	// vvv Галфинд \ Sakovich 31.03.2023
	Или ТипЗнч(Объект.Распоряжение) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг")
	// ^^^ Галфинд \ Sakovich 31.03.2023 
	Или ТипЗнч(Объект.Распоряжение) = Тип("ДокументСсылка.ПроизводствоБезЗаказа")));

	Возврат НужноЗаполнятьШтрихкодыУпаковок;

КонецФункции 

&НаКлиенте
Процедура ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда)

	ТекстВопроса = НСтр("ru='Табличная часть ""Штрихкоды упаковок"" пустая. Будет выполнена "
	+ "попытка заполнения. Продолжить?'");
	ДопПараметры = Новый Структура("Команда", Команда);
	Оповещение = Новый ОписаниеОповещения("гф_ВопросЗаполнитьШтрихкодыУпаковокЗавершение", ЭтотОбъект, ДопПараметры);
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ПровестиДокументВместо(Команда)
	
	// #wortmann {
	// #учет Кодов Маркировки (КМ)
	// Галфинд Sakovich 2022/11/01
	НужноЗаполнятьШтрихкодыУпаковок = ОпределитьНеобходимостьЗаполненияШтрихкодовУпаковок();
	// #wortmann {
	// ++ Галфинд_Домнышева_КР_20_04_2023
	Если УсловиеВопросаПроведения() Тогда
		ЗадатьВопросПредупреждения(Команда);
	// } #wortmann	
	ИначеЕсли НужноЗаполнятьШтрихкодыУпаковок Тогда
		Если Объект.ШтрихкодыУпаковок.Количество() = 0 Тогда
			ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда);
		Иначе
			ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок = Истина;
			ЗаполнитьШтрихкодыУпаковок();
			ПродолжитьВызов(Команда);
		КонецЕсли;
	Иначе
		ПродолжитьВызов(Команда);
	КонецЕсли;
	// } #wortmann

КонецПроцедуры

&НаКлиенте
Процедура гф_ПровестиИЗакрытьВместо(Команда)
	
	// #wortmann {
	// #учет Кодов Маркировки (КМ)
	// Галфинд Sakovich 2022/11/01
	НужноЗаполнятьШтрихкодыУпаковок = ОпределитьНеобходимостьЗаполненияШтрихкодовУпаковок();
	// #wortmann {
	// ++ Галфинд_Домнышева_КР_20_04_2023
	Если УсловиеВопросаПроведения() Тогда
		ЗадатьВопросПредупреждения(Команда);
	// } #wortmann
	ИначеЕсли НужноЗаполнятьШтрихкодыУпаковок Тогда
		Если Объект.ШтрихкодыУпаковок.Количество() = 0 Тогда
			ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда);
		Иначе
			ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок = Истина;
			ЗаполнитьШтрихкодыУпаковок();
			ПродолжитьВызов(Команда);
		КонецЕсли;
	Иначе
		ПродолжитьВызов(Команда);
	КонецЕсли;
	// } #wortmann 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьШтрихкодыУпаковок()
	
	Если Не ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок Тогда
		Возврат;
	КонецЕсли;
	
	Распоряжение = Объект.Распоряжение;
	Если Не (ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров")
		// vvv Галфинд \ Sakovich 31.03.2023
		ИЛИ ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг")
		// ^^^ Галфинд \ Sakovich 31.03.2023 
		ИЛИ ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПроизводствоБезЗаказа")) Тогда
		Возврат;
	КонецЕсли;
	
	Объект.ШтрихкодыУпаковок.Очистить();
	Запрос = Новый Запрос;
	
	Если ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
		СкладОтправитель = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Распоряжение, "СкладОтправитель");
		СкладПолучатель = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Распоряжение, "СкладПолучатель");
		СкладОтправительКоробочный = 
		УправлениеСвойствами.ЗначениеСвойства(СкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
		СкладПолучательКоробочный = 
		УправлениеСвойствами.ЗначениеСвойства(СкладПолучатель, "гф_СкладыТоварыВКоробах") = Истина;
		СкладВиртуальный = ПроверкаСкладаНаВиртуальность(СкладОтправитель);// Галфинд_Домнышева_09_11_2023
		
		Если СкладОтправительКоробочный И СкладПолучательКоробочный Тогда
			// заполняем Агрегатами кодов маркировки
			лТовары = Объект.Товары.Выгрузить();
			
			ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	т.УпаковочныйЛист КАК УпаковочныйЛист,
			|	т.ЭтоУпаковочныйЛист
			|ПОМЕСТИТЬ УпЛисты
			|ИЗ
			|	&Товары КАК т
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки
			|ИЗ
			|	УпЛисты КАК УпЛисты
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
			|		ПО УпЛисты.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода
			|ГДЕ
			|	УпЛисты.ЭтоУпаковочныйЛист
			|	И ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL 
			|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)";
			Запрос.Текст = ТекстЗапроса;
			Запрос.УстановитьПараметр("Товары", лТовары);
			
		ИначеЕсли СкладОтправительКоробочный И Не СкладПолучательКоробочный Тогда
			// заполняем Кодами маркировки
			ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
			|ИЗ
			|	Документ.ПеремещениеТоваров.гф_ТоварыВКоробах КАК ПеремещениеТоваровгф_ТоварыВКоробах
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
			|		ПО ПеремещениеТоваровгф_ТоварыВКоробах.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка.ЗначениеШтрихкода
			|ГДЕ
			|	ПеремещениеТоваровгф_ТоварыВКоробах.Ссылка = &Распоряжение";
			Запрос.Текст = ТекстЗапроса;
			Запрос.УстановитьПараметр("Распоряжение", Распоряжение);
		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПроизводствоБезЗаказа") 
		// vvv Галфинд \ Sakovich 01.04.2023
		ИЛИ ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг")
		// ^^^ Галфинд \ Sakovich 01.04.2023 
		Тогда
		// заполняем вложенными КМ всегда (для прохождения типовой проверки), 
		// нужные Агрегаты формируются при необходимости (если склад - коробочный) 
		// при формировании движений [см. гф_ОбработкаПроведения.ДвиженияКодовМаркировкиПриходныйОрдерНаТовары()]
		ИмяТаблицы = Распоряжение.Метаданные().Имя;
		ТекстЗапроса = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
		|ИЗ
		|	Документ." + ИмяТаблицы + ".гф_ПродукцияВКоробах КАК ПродукцияВКоробах
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ВложенныеШтрихкоды
		|		ПО ПродукцияВКоробах.IDКороба.Код = ВложенныеШтрихкоды.Ссылка.ЗначениеШтрихкода
		|ГДЕ
		|	ПродукцияВКоробах.Ссылка = &Распоряжение";
		Запрос.Текст = ТекстЗапроса;
		Запрос.УстановитьПараметр("Распоряжение", Распоряжение);
	КонецЕсли; 
		
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;	
	КонецЕсли;
	
	тзШтрихкоды = Результат.Выгрузить();
	Объект.ШтрихкодыУпаковок.Загрузить(тзШтрихкоды);
	
КонецПроцедуры 

// #wortmann { 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee7ed187d3b8e2
// Необходимо не перезаполнять ТЧ для Виртуального отправителя
// Галфинд_Домнышева 2023/11/09
&НаСервере
Функция ПроверкаСкладаНаВиртуальность(СкладОтправитель) 
	
	ВиртуальныеСклады = _омОбщегоНазначенияКлиентСервер.ПолучитьГлобальноеЗначениеМассив("гф_ВиртуальныеСклады");
	Если ВиртуальныеСклады.Найти(СкладОтправитель) <> Неопределено Тогда
        Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
	
КонецФункции// } #wortmann

// #wortmann {
// Задает пользователю вопрос о его уверенности в дальнейшем проведении
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8131bcee7bda45d711edd37b5946b51b
// ++ Галфинд_Домнышева_КР_20_04_2023
&НаКлиенте
Процедура ЗадатьВопросПредупреждения(Команда)
	
	ТекстВопроса = "Документ распоряжение - Заявка на Возврат Товаров имеет статус ""К Выполнению"""
	+ Символы.ПС + "Вы хотите продолжить?";
	ДопПараметры = Новый Структура("Команда", Команда);
	ОписаниеОповещения = Новый ОписаниеОповещения("гф_ЗавершениеПредупреждения", ЭтотОбъект, ДопПараметры);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет, "!Внимание!");

КонецПроцедуры// } #wortmann 

// #wortmann {
// Условие выдачи предупреждения о проведении
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8131bcee7bda45d711edd37b5946b51b
// ++ Галфинд_Домнышева_КР_20_04_2023
&НаСервере
Функция УсловиеВопросаПроведения()
	
	 Возврат Объект.Статус = Перечисления.СтатусыПриходныхОрдеров.Принят
		И (ТипЗнч(Объект.Распоряжение) = Тип("ДокументСсылка.ЗаявкаНаВозвратТоваровОтКлиента") И
		Объект.Распоряжение.Статус = Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КОбеспечению);
	
КонецФункции// } #wortmann

// #wortmann {
// Условие выдачи предупреждения о проведении
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8131bcee7bda45d711edd37b5946b51b
// ++ Галфинд_Домнышева_КР_20_04_2023
&НаКлиенте
Процедура гф_ЗавершениеПредупреждения(Результат, ДополнительныеПараметры) Экспорт
	
	Команда = ДополнительныеПараметры["Команда"];
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		НужноЗаполнятьШтрихкодыУпаковок = ОпределитьНеобходимостьЗаполненияШтрихкодовУпаковок();
		
		Если НужноЗаполнятьШтрихкодыУпаковок Тогда
			Если Объект.ШтрихкодыУпаковок.Количество() = 0 Тогда
				ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда);
			Иначе
				ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок = Истина;
				ЗаполнитьШтрихкодыУпаковок();
				ВыполнениеКомандыПроведения(Команда);
			КонецЕсли;
		КонецЕсли; 
		
		ВыполнениеКомандыПроведения(Команда);
	Иначе
		Возврат;
	КонецЕсли;
	
КонецПроцедуры// } #wortmann 

// #wortmann {
// Перенесла часть алгоритма из проц. гф_ВопросЗаполнитьШтрихкодыУпаковокЗавершение
// ++ Галфинд_Домнышева_КР_20_04_2023
&НаКлиенте
Процедура ВыполнениеКомандыПроведения(Команда)
	
	Если Команда["Имя"] = "ПровестиДокумент" Тогда
		ОбщегоНазначенияУТКлиент.Провести(ЭтаФорма, Истина);
	КонецЕсли;
	
	Если Команда["Имя"] = "ПровестиИЗакрыть" Тогда
		ОбщегоНазначенияУТКлиент.ПровестиИЗакрыть(ЭтаФорма, Истина);
	КонецЕсли;

КонецПроцедуры// } #wortmann

#КонецОбласти