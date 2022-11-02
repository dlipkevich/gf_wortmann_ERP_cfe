﻿
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка) 
	
	гф_СоздатьНовыеРеквизиты();
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ПередЗаписьюПосле(Отказ, ПараметрыЗаписи)
	// #wortmann {
	// #учет Кодов Маркиовки (КМ)
	// Галфинд Sakovich 2022/11/01
	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		НужноЗаполнятьШтрихкодыУпаковок = Объект.Статус = 
		ПредопределенноеЗначение("Перечисление.СтатусыПриходныхОрдеров.Принят");
		
		Если НужноЗаполнятьШтрихкодыУпаковок Тогда
			Если Объект.ШтрихкодыУпаковок.Количество() = 0 Тогда
				ТекстВопроса = НСтр("ru='Табличная часть ""Штрихкоды упаковок"" пустая. Будет выполнена "
				+ "попытка заполнения. Продолжить?'");
				ДопПараметры = Новый Структура();
				Оповещение = Новый ОписаниеОповещения("гф_ВопросЗаполнитьШтрихкодыУпаковокЗавершение", ЭтотОбъект, ДопПараметры);
				ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
			Иначе
				ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры

&НаСервере
Процедура гф_ПередЗаписьюНаСервереПосле(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// #wortmann {
	// #учет Кодов Маркиовки (КМ)
	// Галфинд Sakovich 2022/11/02
	ЗаполнитьШтрихкодыУпаковок(ТекущийОбъект);	
	// } #wortmann

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

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
	гф_ЗаполнятьШтрихкодыУпаковок = Результат = КодВозвратаДиалога.Да;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьШтрихкодыУпаковок(ТекущийОбъект)
	
	Если ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок Тогда
		
		ТекущийОбъект.ШтрихкодыУпаковок.Очистить();
		
		Распоряжение = Объект.Распоряжение;
		Если Не (ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров")) Тогда
			Возврат;	
		КонецЕсли;
		
		СкладОтправитель = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Распоряжение, "СкладОтправитель");
		СкладПолучатель = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Распоряжение, "СкладПолучатель");
		СкладОтправительКоробочный = 
		УправлениеСвойствами.ЗначениеСвойства(СкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
		СкладПолучательКоробочный = 
		УправлениеСвойствами.ЗначениеСвойства(СкладПолучатель, "гф_СкладыТоварыВКоробах") = Истина;

		Запрос = Новый Запрос;
		Если СкладОтправительКоробочный И СкладПолучательКоробочный Тогда
			// заполняем Агрегатами кодо маркировки
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
			
		Иначе
			Возврат;
		КонецЕсли;
		
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			Возврат;	
		КонецЕсли;
		
		тзШтрихкоды = Результат.Выгрузить();
		ТекущийОбъект.ШтрихкодыУпаковок.Загрузить(тзШтрихкоды);
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти