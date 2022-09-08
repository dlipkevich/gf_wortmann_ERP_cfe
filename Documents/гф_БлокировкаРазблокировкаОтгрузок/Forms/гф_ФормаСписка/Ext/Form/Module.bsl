﻿#Область ОбработчикиСобытийФормы 
 // #wortmann {
 // Параметры:
// Отказ, СтандартнаяОбработка
// // Типовой функционал для добавления команд
// Функционал для команды по открытию документов из договора
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	Если Параметры.Свойство("ДоговорКонтрагента" ) Тогда
		ДоговорКонтрагента = Параметры.ДоговорКонтрагента;
		УстановитьОтборПоДоговоруКонтрагентаИКонтрагенту();
	КонецЕсли;  
	
КонецПроцедуры
// } #wortmann

// #wortmann {
 // Параметры:
// Элемент
// // Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры
// } #wortmann

#КонецОбласти

#Область ОбработчикиСобытийЭлементовСтраницыФормыОсновная 
// #wortmann {
// Замена запроса для динамического списка
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура ИсторияНаСервере()
	Список.ТекстЗапроса = ПолучитьЗапросДляДинамическогоСписка();
КонецПроцедуры
// } #wortmann 

// #wortmann {
 // Параметры:
// Команда
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура История(Команда)
	ИсторияНаСервере();
КонецПроцедуры
// } #wortmann

// #wortmann { 
// Замена запроса для динамического списка
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
// Возвращаемое значение:
// Запрос.Текс - текст запроса
&НаСервере
Функция ПолучитьЗапросДляДинамическогоСписка()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	гф_БлокировкаРазблокировкаОтгрузок.Ссылка КАК Ссылка,
	|	гф_БлокировкаРазблокировкаОтгрузок.Номер КАК Номер,
	|	гф_БлокировкаРазблокировкаОтгрузок.Дата КАК Дата,
	|	гф_БлокировкаРазблокировкаОтгрузок.Организация КАК Организация,
	|	гф_БлокировкаРазблокировкаОтгрузок.Контрагент КАК Контрагент,
	|	гф_БлокировкаРазблокировкаОтгрузок.ДоговорКонтрагента КАК ДоговорКонтрагента,
	|	гф_БлокировкаРазблокировкаОтгрузок.ВидБлокировки КАК ВидБлокировки,
	|	гф_БлокировкаРазблокировкаОтгрузок.Заблокирован КАК Заблокирован,
	|	гф_БлокировкаРазблокировкаОтгрузок.Исключения КАК Исключения,
	|	гф_БлокировкаРазблокировкаОтгрузок.Согласовано КАК Согласовано,
	|	гф_БлокировкаРазблокировкаОтгрузок.Комментарий КАК Комментарий,
	|	гф_БлокировкаРазблокировкаОтгрузок.Ответственный КАК Ответственный
	|ИЗ
	|	Документ.гф_БлокировкаРазблокировкаОтгрузок КАК гф_БлокировкаРазблокировкаОтгрузок";
	
	Возврат Запрос.Текст;  
	
КонецФункции
// } #wortmann

// #wortmann {
// Отбор формы списка по договору контрагента ,для открытия из договора
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура УстановитьОтборПоДоговоруКонтрагентаИКонтрагенту()	
	
	ЭлементОтбораПоДоговору = Список.КомпоновщикНастроек.ФиксированныеНастройки.Отбор.
	Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбораПоДоговору.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДоговорКонтрагента");
	ЭлементОтбораПоДоговору.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбораПоДоговору.ПравоеЗначение = ДоговорКонтрагента;		
	
КонецПроцедуры
// } #wortmann

#КонецОбласти

#Область ПодключаемыеКоманды 

// СтандартныеПодсистемы.ПодключаемыеКоманды

// #wortmann {
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	
	ОчиститьСообщения();
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Элементы.Список);
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат) Экспорт
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Элементы.Список, Результат);
КонецПроцедуры
 // } #wortmann
 
// #wortmann {
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Элементы.Список);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
// } #wortmann
#КонецОбласти